이 문서에서는 GitHub와 Jira를 자동으로 연동하여 개발 프로세스를 간소화하고 추적 가능하게 만드는 워크플로우에 대해 설명합니다.  

## 기능 개요

- GitHub에서 이슈 생성 시 자동으로 Jira 태스크 생성
- 생성된 Jira 티켓 번호로 GitHub 브랜치 자동 생성
- Jira에서 연결된 GitHub 저장소의 커밋 및 PR 내용 확인 가능

## 워크플로우 상세 설명
### 1. GitHub 이슈 생성 시 Jira 태스크 자동 생성
- GitHub에서 새로운 이슈가 생성되면, .github/workflows 디렉토리에 정의된 GitHub Actions 워크플로우가 트리거됩니다.
- 워크플로우는 .github/ISSUE_TEMPLATE/issue-form.yml 파일에 정의된 이슈 템플릿을 사용하여 이슈 정보를 파싱합니다.
- 파싱된 정보를 바탕으로 Jira API를 호출하여 새로운 태스크를 자동으로 생성합니다.
- 생성된 Jira 태스크에는 GitHub 이슈 링크가 포함됩니다.

### 2. Jira 티켓 번호로 GitHub 브랜치 자동 생성
- Jira에서 생성된 태스크의 티켓 번호를 추출합니다.
- 추출된 티켓 번호를 이름으로 하는 새로운 GitHub 브랜치를 자동으로 생성합니다.
- 생성된 브랜치는 dev 브랜치에서 분기되며, 원격 저장소로 푸시됩니다.

### 3. Jira에서 GitHub 커밋 및 PR 내용 확인
- 전송된 커밋 및 PR 정보는 연결된 Jira 태스크에 자동으로 업데이트됩니다.
- Jira 태스크에서 GitHub 저장소의 커밋 내역과 PR 상태를 한눈에 확인할 수 있습니다.

## 기술 구현 상세
### GitHub Actions 워크플로우
- .github/workflows 디렉토리에 정의된 GitHub Actions 워크플로우는 이슈 생성 이벤트를 트리거로 사용합니다.
- 워크플로우는 Jira API 호출을 위해 필요한 인증 정보(base URL, API token, user email)를 시크릿으로 관리합니다.
- stefanbuck/github-issue-parser 액션을 사용하여 이슈 템플릿에 맞춰 생성된 이슈 정보를 파싱합니다.
- peter-evans/jira2md 액션을 사용하여 마크다운 형식의 이슈 내용을 Jira 문법으로 변환합니다.
- atlassian/gajira-create 액션을 사용하여 Jira에 새로운 태스크를 생성하고, 태스크 키를 출력합니다.
- actions/checkout 액션을 사용하여 main 브랜치의 코드를 체크아웃하고, 새로운 브랜치를 생성하여 푸시합니다.
- actions-cool/issues-helper 액션을 사용하여 생성된 이슈의 제목을 Jira 태스크 키로 업데이트합니다.

### 이슈 템플릿
- .github/ISSUE_TEMPLATE/issue-form.yml 파일에 이슈 템플릿을 정의합니다.
- 템플릿에는 상위 작업 티켓 번호, 이슈 내용, 상세 내용, 체크리스트, 참조 등의 필드가 포함됩니다.
- 각 필드에는 라벨, 설명, 플레이스홀더 등의 속성을 지정할 수 있습니다.

이렇게 GitHub Actions 워크플로우와 이슈 템플릿을 활용하여 GitHub와 Jira를 자동으로 연동하는 워크플로우를 구현하였습니다. 이를 통해 이슈 관리와 코드 관리를 효율적으로 수행할 수 있게 됩니다.