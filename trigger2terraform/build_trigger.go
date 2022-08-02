package main

type BuildTrigger struct {
	CreateTime       string                      `json:"createTime"`
	Description      string                      `json:"description"`
	Filename         string                      `json:"filename"`
	Disabled         bool                        `json:"disabled"`
	GitFileSource    BuildTriggerGitFileSource   `json:"gitFileSource"`
	ID               string                      `json:"id"`
	Name             string                      `json:"name"`
	SourceToBuild    BuildTriggerSourceToBuild   `json:"sourceToBuild"`
	Substitutions    map[string]string           `json:"substitutions"`
	Github           BuildTriggerGithub          `json:"github"`
	Tags             []string                    `json:"tags"`
	IncludedFiles    []string                    `json:"includedFiles"`
	IgnoredFiles     []string                    `json:"ignoredFiles"`
	IncludeBuildLogs string                      `json:"includeBuildLogs"`
	TriggerTemplate  BuildTriggerTriggerTemplate `json:"triggerTemplate"`
}

type BuildTriggerGitFileSource struct {
	Path     string `json:"path"`
	RepoType string `json:"repoType"`
	Revision string `json:"revision"`
	URI      string `json:"uri"`
}

type BuildTriggerSourceToBuild struct {
	Ref      string `json:"ref"`
	RepoType string `json:"repoType"`
	URI      string `json:"uri"`
}

type BuildTriggerGithub struct {
	Name        string                        `json:"name"`
	Owner       string                        `json:"owner"`
	PullRequest BuildTriggerGithubPullRequest `json:"pullRequest"`
	Push        BuildTriggerGithubPush        `json:"push"`
}

type BuildTriggerGithubPush struct {
	Branch string `json:"branch"`
	Tag    string `json:"tag"`
}

type BuildTriggerGithubPullRequest struct {
	Branch string `json:"branch"`
}

type BuildTriggerTriggerTemplate struct {
	BranchName string `json:"branchName"`
	ProjectID  string `json:"projectId"`
	RepoName   string `json:"repoName"`
}
