package main

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"html/template"
	"io/ioutil"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"time"

	// cloudbuild "cloud.google.com/go/cloudbuild/apiv1/v2"
	"github.com/golang-jwt/jwt/v4"
	"github.com/manifoldco/promptui"
	"github.com/mitchellh/go-homedir"
	"github.com/securisec/cliam/gcp"
	"github.com/securisec/cliam/shared"
	"github.com/sirupsen/logrus"
	// cloudbuildpb "google.golang.org/genproto/googleapis/devtools/cloudbuild/v1"
)

var (
	gcpServiceAccountPath string
	gcpProjectId          string
	gcpRegion             string
	gcpZone               string
	gcpAccessToken        string
)

func main() {

	triggerId := os.Args[1]
	if len(triggerId) == 0 {
		logrus.Fatal("Must pass in triggerId")
	}
	// logrus.Warn(triggerId)

	sa, projectId, _, _ := getSaAndRegion()

	ctx := context.Background()
	accessToken, err := gcp.GetAccessToken(ctx, sa)
	if err != nil {
		logrus.WithError(err).Fatal("Failed to get access token")
	}
	// fmt.Println(accessToken)

	var httpReq *http.Request

	// triggerId := "b507b0b1-4463-4f0e-8c8f-7e0774733f8a"
	url := fmt.Sprintf("https://cloudbuild.googleapis.com/v1/projects/%s/triggers/%s", projectId, triggerId)
	isGet := true
	reqMethod := "GET"
	reqBody := ""

	// logrus.Warn(url)
	if isGet {
		httpReq, err = http.NewRequestWithContext(ctx, reqMethod, url, nil)
		if err != nil {
			logrus.WithError(err).Error("Failed to set request")
		}
	} else {
		o, err := json.Marshal(reqBody)
		if err != nil {
			logrus.WithError(err).Error("Failed to marshall REQ body")
		}
		httpReq, err = http.NewRequestWithContext(context.TODO(), reqMethod, url, bytes.NewBuffer(o))
		if err != nil {
			logrus.WithError(err).Error("Failed to set request")
		}
	}
	if !isGet {
		httpReq.Header.Add("Content-Type", "application/json")
	}

	// add auth bearer token
	httpReq.Header.Add("Authorization", "Bearer "+accessToken)
	httpReq.Header.Add("user-agent", "google-cloud-sdk gcloud/379.0.0")

	res, err := http.DefaultClient.Do(httpReq)
	if err != nil {
		logrus.WithError(err).Error("Failed to call REST")
	}

	body, err := ioutil.ReadAll(res.Body)
	if err != nil {
		logrus.WithError(err).Error("Failed to read REST data")
	}
	res.Body.Close()

	// logrus.Warn(string(body[:]))

	bt := BuildTrigger{}
	if err := json.Unmarshal(body, &bt); err != nil {
		logrus.WithError(err).Fatal("DEBUG: failed to marshall the JSON")
	}

	// logrus.Warn(fmt.Sprintf("%#v", bt))

	logrus.Infof("Processing %s (%s)", bt.ID, bt.Name)

	fmt.Printf("resource \"google_cloudbuild_trigger\" \"%s\" {\n", strings.ToLower(bt.Name))
	// fmt.Printf("    project = %s\n", resp.TriggerTemplate.ProjectId)
	fmt.Printf("    name = \"%s\"\n", bt.Name)
	fmt.Printf("    description = \"%s\"\n", bt.Description)
	if bt.Disabled {
		fmt.Printf("    disabled = %t\n", bt.Disabled)
	}
	if bt.Filename != "" {
		fmt.Printf("    filename = \"%s\"\n", bt.Filename)
	}
	if bt.IncludeBuildLogs != "" {
		fmt.Printf("    include_build_logs= \"%s\"\n", bt.IncludeBuildLogs)
	}
	fmt.Println()
	if bt.Github.Name != "" {
		fmt.Println("    github {")
		fmt.Printf("        owner = \"%s\"\n", bt.Github.Owner)
		fmt.Printf("        name = \"%s\"\n", bt.Github.Name)
		if bt.Github.PullRequest.Branch != "" {
			fmt.Println("        pull_request {")
			fmt.Printf("            branch = \"%s\"\n", bt.Github.PullRequest.Branch)
			fmt.Println("    }")
		}
		if bt.Github.Push.Branch != "" || bt.Github.Push.Tag != "" {
			fmt.Println("        push {")
			if bt.Github.Push.Branch != "" {
				fmt.Printf("            branch = \"%s\"\n", bt.Github.Push.Branch)
			}
			if bt.Github.Push.Tag != "" {
				fmt.Printf("            tag = \"%s\"\n", bt.Github.Push.Tag)
			}
			fmt.Println("    }")
		}
		fmt.Println("    }")
	}
	if bt.GitFileSource.RepoType != "" {
		fmt.Println("    git_file_source {")
		fmt.Printf("        path = \"%s\"\n", bt.GitFileSource.Path)
		fmt.Printf("        uri = \"%s\"\n", bt.GitFileSource.URI)
		fmt.Printf("        repo_type = \"%s\"\n", bt.GitFileSource.RepoType)
		fmt.Printf("        revision = \"%s\"\n", bt.GitFileSource.Revision)
		fmt.Println("    }")
	}
	if bt.SourceToBuild.RepoType != "" {
		fmt.Println("    source_to_build {")
		fmt.Printf("        uri = \"%s\"\n", bt.SourceToBuild.URI)
		fmt.Printf("        repo_type = \"%s\"\n", bt.SourceToBuild.RepoType)
		fmt.Printf("        ref = \"%s\"\n", bt.SourceToBuild.Ref)
		fmt.Println("    }")
	}
	if bt.TriggerTemplate.BranchName != "" || bt.TriggerTemplate.RepoName != "" {
		fmt.Println("    trigger_template {")
		fmt.Printf("        branch_name = \"%s\"\n", bt.TriggerTemplate.BranchName)
		fmt.Printf("        project_id = \"%s\"\n", bt.TriggerTemplate.ProjectID)
		fmt.Printf("        repo_name = \"%s\"\n", bt.TriggerTemplate.RepoName)
		fmt.Println("    }")
	}
	if bt.IncludedFiles != nil {
		fmt.Println("    included_files = [")
		for _, v := range bt.IncludedFiles {
			fmt.Printf("        \"%s\",\n", v)
		}
		fmt.Println("    ]")
	}
	if bt.IgnoredFiles != nil {
		fmt.Println("    ignored_files = [")
		for _, v := range bt.IgnoredFiles {
			fmt.Printf("        \"%s\",\n", v)
		}
		fmt.Println("    ]")
	}
	if bt.Substitutions != nil {
		fmt.Println("    substitutions = {")
		for k, v := range bt.Substitutions {
			fmt.Printf("        %s = \"%s\"\n", k, v)
		}
		fmt.Println("    }")
	}
	if bt.Tags != nil {
		// fmt.Printf("    tags = \"%s\"\n", bt.Tags)
		fmt.Println("    tags = [")
		for _, v := range bt.Tags {
			fmt.Printf("        \"%s\",\n", v)
		}
		fmt.Println("    ]")
	}
	fmt.Println("}")

	fmt.Println()

	// FAIL: I tried to use the google cloudbuild code, it is experimental and doesn't export ALL
	// of the required fields needed to properly build out the terraform.

	// c, err := cloudbuild.NewClient(context.Background())
	// if err != nil {
	// 	// return nil, errors.New(fmt.Sprintf("Error creating Cloud Build client: %v", err.Error()))
	// 	fmt.Println("Error1")
	// }

	// req := &cloudbuildpb.GetBuildTriggerRequest{
	// 	ProjectId: "spry-effect-244215",
	// 	TriggerId: "b507b0b1-4463-4f0e-8c8f-7e0774733f8a",
	// }

	// resp, err := c.GetBuildTrigger(context.Background(), req)
	// if err != nil {
	// 	// return nil, errors.New(fmt.Sprintf("error getting build from API; check project and build ID: %v; ", err.Error()))
	// 	fmt.Println("Error2")
	// }

	// // fmt.Printf("%#v\n", resp)
	// logrus.Warn(fmt.Sprintf("%#v", resp.String()))
	// logrus.Warn(fmt.Sprintf("%#v", resp.TriggerTemplate))
	// logrus.Warn(fmt.Sprintf("%#v", resp.Github))
	// logrus.Warn(fmt.Sprintf("%#v", resp.PubsubConfig))
	// logrus.Warn(fmt.Sprintf("%#v", resp.WebhookConfig))
	// logrus.Warn(fmt.Sprintf("%#v", resp.BuildTemplate))

	// fmt.Println("resource \"google_cloudbuild_trigger\" \"build-trigger\" {")
	// // fmt.Printf("    project = %s\n", resp.TriggerTemplate.ProjectId)
	// fmt.Printf("    name = \"%s\"\n", resp.Name)
	// fmt.Printf("    description = \"%s\"\n", resp.Description)
	// fmt.Printf("    disabled = %t\n", resp.Disabled)
	// if resp.TriggerTemplate != nil || resp.Github != nil {
	// 	if resp.GetFilename() != "" {
	// 		fmt.Printf("    filename = \"%s\"\n", resp.GetFilename())
	// 	}
	// }
	// if resp.IgnoredFiles != nil {
	// 	fmt.Printf("    ignored_files = \"%s\"\n", resp.IgnoredFiles)
	// }
	// if resp.IncludedFiles != nil {
	// 	fmt.Println("    included_files = [")
	// 	for _, v := range resp.IncludedFiles {
	// 		fmt.Printf("        \"%s\",\n", v)
	// 	}
	// 	fmt.Println("    ]")
	// }
	// if resp.PubsubConfig != nil || resp.WebhookConfig != nil {
	// 	if resp.Filter != "" {
	// 		fmt.Printf("    filter = \"%s\"\n", resp.Filter)
	// 	}
	// 	// git_file_source block (https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudbuild_trigger#nested_git_file_source)
	// 	fmt.Println("    git_file_source {")
	// 	fmt.Println("    }")

	// }
	// if resp.ServiceAccount != "" {
	// 	fmt.Printf("    service_account = \"%s\"\n", resp.ServiceAccount)
	// }
	// fmt.Println()
	// if resp.Substitutions != nil {
	// 	fmt.Println("    substitutions {")
	// 	for k, v := range resp.Substitutions {
	// 		fmt.Printf("        %s = \"%s\"\n", k, v)
	// 	}
	// 	fmt.Println("    }")
	// }

	// TODO: include_build_logs (terraform property, not present in BuildTrigger structure)

	// fmt.Println("}")
}

func getSaAndRegion() (string, string, string, string) {
	return getSaPath(), getProjectId(), gcpRegion, gcpZone
}

func getSaPath() string {
	if gcpAccessToken != "" {
		return ""
	}
	if gcpServiceAccountPath != "" {
		return expandPath(gcpServiceAccountPath)
	}
	if k, ok := os.LookupEnv("GOOGLE_APPLICATION_CREDENTIALS"); ok {
		return k
	}
	return expandPath(promptInput("GCP service account path: "))
}

func getProjectId() string {
	if gcpProjectId != "" {
		return gcpProjectId
	}
	if k, ok := os.LookupEnv("CLOUDSDK_CORE_PROJECT"); ok {
		return k
	}
	return promptInput("GCP project id: ")
}

func expandPath(p string) string {
	h, err := homedir.Expand(p)
	if err != nil {
		logrus.WithError(err).Fatal("failed to expand path")
	}
	ps, err := filepath.Abs(h)
	if err != nil {
		logrus.WithError(err).Fatal("failed to get absolute path")
	}
	return ps
}

func printValidArgs(f func() []string) {
	fmt.Println(shared.Red("Valid arguments:"))
	for _, v := range f() {
		fmt.Println(v)
	}
}

func getRequest(url, service string) (int, error) {
	logrus.Debug("url", url)
	res, err := http.Get(url)
	if err != nil {
		return 0, err
	}
	status := res.StatusCode
	if status == 200 {
		logrus.Info("success", service, "url", url)
		return status, nil
	} else {
		logrus.Debug("failed", status)
	}
	return status, fmt.Errorf("Bad status: %d", status)
}

func templateBuilder(t string, args map[string]string) (string, error) {
	temp := template.Must(template.New("").Parse(t))
	var tpl bytes.Buffer
	err := temp.Execute(&tpl, args)
	return tpl.String(), err
}

func ValidateJwtExpiration(token string) (isValid bool) {
	j, _, err := new(jwt.Parser).ParseUnverified(token, jwt.MapClaims{})
	if err != nil {
		logrus.WithError(err).Error("Failed to parse JWT")
	}
	// if exp field is not set, we want to return true
	return j.Claims.(jwt.MapClaims).VerifyExpiresAt(time.Now().Unix(), false)
}

// promptInput is a helper function to prompt the user for input.
func promptInput(msg string) string {
	prompt := promptui.Prompt{
		Label: msg,
	}
	p, err := prompt.Run()
	if err != nil {
		logrus.WithError(err).Error("")
		os.Exit(1)
	}
	// trim whitespace
	return strings.Trim(p, " ")
}
