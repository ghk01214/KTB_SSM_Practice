# KTB_SSM_Practice

## 개요
---
`KTB_SSM_Practice`는 `AWS System Manager`의 `Session Manager`를 사용하는 기본 예제입니다. 이 repo에서는 `SSM`을 사용해서 SSH 키 페어 없이 private instance에 접근하는 방법을 소개합니다.

## 목표
---
이 repo는 `SSM`을 이용해서 private instance에 `Docker`와 `Docker-Compose`를 설치한 뒤 `nginx` 이미지를 받아와서 배포하는 작업을 `Ansible playbook`을 통해 이루어지도록 하고 있습니다.

## 환경 구성
---
실습을 진행하기에 앞서 다음과 같은 사전 준비가 필요합니다.

1. Python3, AWS CLI, AWS session-manager-plugin, boto3 설치
SSM은 AWS API를 이용한 작업이므로 위 패키지들의 설치가 필요합니다.

##### Windows
추가 예정

##### macOS(Apple Silicon)
aws cli 설치
```bash
brew install awscli
```
session-manager-plugin 설치
```bash
brew install aws-session-manager-plugin

# 패키지가 성공적으로 설치됐는지 확인
session-manager-plugin

# 성공적으로 설치됐으면 아래의 메시지 반환
# The Session Manager plugin is installed successfully. Use the AWS CLI to start a session.
```
위 방법이 작동하지 않을 경우 아래의 방법을 이용
```bash
# aws session-manager-plugin 패키지 다운로드
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/mac_arm64/sessionmanager-bundle.zip" -o "sessionmanager-bundle.zip"
# Intel Mac은 아래 명령줄 사용
# curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/mac/sessionmanager-bundle.zip" -o "sessionmanager-bundle.zip"

# 패키지 압축 해제
unzip sessionmanager-bundle.zip

# 패키지 설치 실행
sudo ./sessionmanager-bundle/install -i /usr/local/sessionmanagerplugin -b /usr/local/bin/session-manager-plugin

# 패키지가 성공적으로 설치됐는지 확인
session-manager-plugin

# 성공적으로 설치됐으면 아래의 메시지 반환
# The Session Manager plugin is installed successfully. Use the AWS CLI to start a session.
```
boto3 설치
```bash
pip install boto3
```


