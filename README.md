# KTB_SSM_Practice

## 개요
`KTB_SSM_Practice`는 `AWS System Manager`의 `Session Manager`를 사용하는 기본 예제입니다. 이 repo에서는 `SSM`을 사용해서 SSH 키 페어 없이 private instance에 접근하는 방법을 소개합니다.

## 목표
이 repo는 `SSM`을 이용해서 private instance에 `Docker`와 `Docker-Compose`를 설치한 뒤 `nginx` 이미지를 받아와서 배포하는 작업을 `Ansible playbook`을 통해 이루어지도록 하고 있습니다.

## 환경 구성
실습을 진행하기에 앞서 다음과 같은 환경 구성이 필요합니다.

1. Python3, AWS CLI, AWS session-manager-plugin, boto3 설치
SSM은 AWS API를 이용한 작업이므로 위 패키지들의 설치가 필요합니다.

#### Windows
***aws cli 설치***

winget 사용
```powershell
winget install awscli
```
설치 관리자 이용
```powershell
msiexec.exe /i https://awscli.amazonaws.com/AWSCLIV2.msi
```
이 명령어를 powershell에 입력하거나
> https://awscli.amazonaws.com/AWSCLIV2.msi

해당 링크에서 직접 msi 파일을 다운로드 후 설치

***session-manager-plugin 설치***
> https://s3.amazonaws.com/session-manager-downloads/plugin/latest/windows/SessionManagerPluginSetup.exe

위 링크의 exe 파일을 다운로드 후 설치

설치 확인
```powershell
aws --version
```
***boto3 설치***
```bash
pip install boto3
```

---

#### macOS
***aws cli 설치***

Homebrew 사용
```bash
brew install awscli
```
설치 관리자 이용
> https://awscli.amazonaws.com/AWSCLIV2.pkg

curl 사용
```bash
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /
```

해당 링크에서 직접 pkg 파일 다운로드 후 설치

설치 확인
```bash
which aws
aws --version
```

***session-manager-plugin 설치***

Homebrew 사용
```bash
brew install aws-session-manager-plugin
```
curl 사용

Apple Silicon(M series)
```bash
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/mac_arm64/sessionmanager-bundle.zip" -o "sessionmanager-bundle.zip"
```
Intel Mac
```bash
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/mac/sessionmanager-bundle.zip" -o "sessionmanager-bundle.zip"
```
설치
```bash
# 패키지 압축 해제
unzip sessionmanager-bundle.zip

# 패키지 설치 실행
sudo ./sessionmanager-bundle/install -i /usr/local/sessionmanagerplugin -b /usr/local/bin/session-manager-plugin
```
설치 확인
```bash
# 패키지가 성공적으로 설치됐는지 확인
session-manager-plugin

# 설치에 성공하면 다음 메시지가 반환
# The Session Manager plugin is installed successfully. Use the AWS CLI to start a session.
```
***boto3 설치***
```bash
pip install boto3
```
2. Terraform, Ansible 설치

아래 참고자료 확인

3. 인스턴스 역할 생성

IAM에서 역할 생성->사용 사례에서 EC2 Role for AWS Systems Manager 선택
![엔티티 선택](asset/Screenshot%202024-11-25%2016.45.40.png)

역할 이름: ec2-ssm으로 설정
![역할 이름 설정](asset/Screenshot%202024-11-25%2016.46.08.png)

4. SSM 로그 수집을 위한 S3 버킷 생성

기본 설정으로 생성
![버킷 생성](asset/Screenshot%202024-11-25%2022.44.33.png)

## 리소스 생성
Terraform을 이용해 실습에 필요한 리소스 생성

생성되는 리소스 종류
- Public subnet 2개
- Private subnet 1개
- Elastic IP 1개
- NAT Gateway 1개
- 기본 보안 그룹 1개
    - ingress로 80번 포트만 허용(http)
- Private instance EC2 1개(Amazon Linux 2023)
- Application Load Balancer 1개
- Instance로 forwarding하는 target group 1개

리소스 생성을 위한 디렉터리 이동 후 리소스 생성
```bash
cd /<repo를_클론한_위치>/KTB_SSM_Practice/Terraform
terraform apply
```

실행 결과물로 생성한 인스턴스 id와 로드 밸런서의 엔드포인트 url이 출력될 것이다.

***이 것을 어딘가에 복사해 두자.***

실습 종료 후 리소스 삭제
```bash
terraform destroy
```

## EC2 접근
다음의 명령어를 실행하면 SSH 접속을 한 것과 동일하게 EC2에 접근

<your_instance_id>는 생성된 인스턴스의 id로 변경
```bash
aws ssm start-session \
    --document-name AWS-StartInteractiveCommand \
    --parameters command="sudo su - ec2-user" \
    --target <your_instance_id>
```
명령어 설명</br>
<u>ssm start-session</u>: ssm으로 세션을 시작</br>
<u>--document-name AWS-StartInteractiveCommand</u>: 세션 시작 시 명령 실행</br>
<u>--parameters command="sudo su - ec2-user"</u>: ec2-user로 로그인</br>
<u>--target <your_instance_id></u>: 접속할 인스턴스를 id로 지정

## 플레이북 실행
명령 실행을 휘한 디렉터리 이동 후 플레이북 실행
```bash
cd /<repo를 클론한 위치>/KTB_SSM_Practice/Ansible
ansible-playbook playbook.yaml
```
위 명령을 실행하면 다음의 내용 실행
1. 먼저 생성된 리소스에 Docker와 docker-compose를 설치한다.
2. 다음으로 docker-compose 파일을 생성하고 백그라운드로 실행한다.
3. 마지막으로 실행 결과인 docker container 목록을 출력한다.

모든 명령이 완료되면 사전에 복사해 둔 로드밸런서 url로 접근해 nginx가 작동하는지 확인한다.

## 부록 - 포트포워딩
다음의 명령어를 실행하면 SSH를 통해 포트포워딩 한 것과 동일하게 작동

주로 RDS나 ingress ip를 강하게 제한한 ec2 등 직접 접속이 제한되는 리소스에 사용
```bash
aws ssm start-session \
    --document-name AWS-StartPortForwardingSessionToRemoteHost \
    --parameters '{"host":[”<host_address>"],"portNumber":[”<remote_port_number>"], "localPortNumber":[”<local_port_number>"]}’ \
    --target <your_instance_id>

```

<u>--document-name AWS-StartPortForwardingSessionToRemoteHost</u>: 세션 시작 시 인스턴스를 프록시 점프로 이용한 포트포워딩을 통해 remote host에 접근</br>
<u>--parameters</u></br>
&emsp;- host: 실제로 접속할 remote host</br>
&emsp;- portNumber: remote에서 ingress로 허용한 포트 번호</br>
&emsp;- localPortNumber: 로컬에서 portNumber와 연결할 포트 번호</br>

다음의 명령어를 실행하면 SSH를 통해 포트포워딩 한 것과 동일하게 작동

주로 컨테이너 형태로 실행되는 DB에 접근할 때 사용
```bash
aws ssm start-session \
    --document-name AWS-StartPortForwardingSession \
    --parameters '{"portNumber":[”<remote_port_number>"], "localPortNumber":[”<local_port_number>"]}’ \
    --target <your_instance_id>
```

<u>--document-name AWS-StartPortForwardingSessionToRemoteHost</u>: 세션 시작 시 포트포워딩 방식으로 접근</br>
<u>--parameters</u></br>
&emsp;- host: 실제로 접속할 remote host</br>
&emsp;- portNumber: remote에서 ingress로 허용한 포트 번호</br>
&emsp;- localPortNumber: 로컬에서 portNumber와 연결할 포트 번호</br>

## 참고 자료
[AWS SSM으로 EC2 인스턴스에 접근하기 (SSH 대체)](https://musma.github.io/2019/11/29/about-aws-ssm.html)

[최신 버전 AWS CLI 설치 또는 업데이트 공식 문서](https://docs.aws.amazon.com/ko_kr/cli/latest/userguide/getting-started-install.html)

[Session Manager Plugin 설치 공식 문서](https://docs.aws.amazon.com/ko_kr/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html)

[Terraform 설치 공식 문서](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

[Ansible 설치 공식 문서](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)