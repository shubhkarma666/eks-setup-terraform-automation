# 🚀 EKS Terraform Setup

Provision an AWS EKS (Elastic Kubernetes Service) cluster using Terraform and deploy apps using kubectl.

---

## 📌 Prerequisites

- Instance: Minimum **2 CPU & 4GB RAM**
  - Example: `t2.medium` or `c7i-flex.large`
- OS: Ubuntu / Linux
- AWS Account with IAM credentials

---

## ⚙️ Install Dependencies

### 1️⃣ AWS CLI

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

Configure AWS:

```bash
aws configure
```

Enter:
- AWS Access Key
- AWS Secret Key
- Region (e.g., `us-east-1`)

📖 Docs: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

---

### 2️⃣ Terraform

```bash
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update && sudo apt install terraform
```

Verify:

```bash
terraform -v
```

📖 Docs: https://developer.hashicorp.com/terraform/install

---

## 🏗️ Deploy EKS Cluster

```bash
terraform init
terraform plan
terraform apply --auto-approve
```

---

## ☸️ Install kubectl

kubectl is used to interact with Kubernetes cluster.

```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"

sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

Verify:

```bash
kubectl version --client
```

---

## 🔗 Connect to EKS Cluster

```bash
aws eks update-kubeconfig --region <region> --name <cluster-name>
```

Example:

```bash
aws eks update-kubeconfig --region ap-south-1 --name shubham-cluster
```

---

## 📄 Get Kubeconfig

```bash
cat ~/.kube/config
```

---

## 🔐 GitHub Actions Setup

1. Copy kubeconfig content  
2. Go to: **GitHub → Repository → Settings → Secrets**  
3. Add new secret:

```
Name: EKS_KUBECONFIG
Value: <paste kubeconfig content>
```

---

## ✅ Verify Deployment

```bash
kubectl get all
```

- Copy the **ALB URL**
- Open in browser

---

## 🎉 Success

Your application is successfully deployed on AWS EKS 🚀