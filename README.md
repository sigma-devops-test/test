# Sigma DevOps Test

### 1. Create GitHub repository
Chose to do monorepo for the sake of simplicity.

### 2. Install Docker Desktop

### 3. Configure Environment

3.1 Download and install Base Ubuntu (Windows CMD):
```cmd
set project=sigma
set project_path=%homepath%\.wsl
set os_version=22.04
mkdir %project_path%
curl -o %project_path%\ubuntu-%os_version%.tar.gz ^
  http://cdimage.ubuntu.com/ubuntu-base/releases/%os_version%/release/ubuntu-base-%os_version%-base-amd64.tar.gz
wsl --import %project% %project_path%\%project% %project_path%\ubuntu-%os_version%.tar.gz --version 2
wsl -d %project%
```

3.2 Configure WSL:
```bash
apt-get update && apt-get upgrade -y && apt-get install -y sudo curl git
groupadd admin
username=sigma
useradd -m -G admin docker -s /bin/bash $username
# No SystemD on base image.
tee -a /etc/wsl.conf <<EOT
[user]
default=$username
EOT
mkdir -p /home/${username}/.config/nvim
cat <<'EOF' > /home/${username}/.config/nvim/init.lua
vim.opt.number = true
vim.opt.relativenumber = true
vim.keymap.set("n", "<C-s>", ":w<CR>")
vim.keymap.set("i", "<C-s>", "<Esc>:w<CR>li")
vim.keymap.set("n", "<S-Q>", ":q<CR>")
EOF
passwd $username && exit
```

3.3:
```cmd
wsl --terminate %project%
wsl -d %project%
```

3.4 Set up environment for Docker (WSL):
```bash
cd
git clone https://github.com/sigma-devops-test/test.git
cd test
docker build -t sigma .
docker run \
  -v $(pwd):/home/sigma/test \
  -v ~/.ssh:/home/sigma/.ssh \
  -v ~/.azure:/home/sigma/.azure \
  -v ~/.kube:/home/sigma/.kube \
  -v ~/.config:/home/sigma/.config \
  -it --name sigma --rm -w /home/sigma/test sigma
```

### 4. Create Azure account

#### 4.1 Study

Learn about Accounts, Users, Services, Authentications.

Learn the best and safest way to authenticate to Azure programatically so to run Terraform etc.

Learn about Network Architecture and AKS Cluster dependencies (VPC, subnets, security rules, endpoints, etc).

What is:
  - Tenant ID
  - Subscription ID
  - Resource Group
  - Azure Resource Providers

### 5. Create Service Princial for programmatic use
```bash
az login
export ARM_SUBSCRIPTION_ID="$(az account list --query "[0].id" -o tsv)"
cd terraform
az ad sp create-for-rbac --name "sigma-devops" --role "User Access Administrator" --scopes /subscriptions/$ARM_SUBSCRIPTION_ID > .azure
```

### 6. Create Terraform modules and resources
1. `test` module: 
   - d
1. `aks` module:
   - d
1. `base` module:
   - d

### 7. Terraform apply
```bash
export ARM_SUBSCRIPTION_ID="$(az account list --query "[0].id" -o tsv)"
terraform apply
```

### 8. Login to ASK with kubectl as Service Principal
```bash
eval $(jq -r '["az login --service-principal -u \"\(.appId)\" -p \"\(.password)\" --tenant \"\(.tenant)\" && export ARM_TENANT_ID=\"\(.tenant)\""][]' .azure)
az aks get-credentials --resource-group sigma --name sigma
kubelogin convert-kubeconfig -l azurecli
```

### 9. Deploy WordPress
#### 9.1 Deploy MySQL
#### 9.2 Deploy WordPress

### 10. Deploy NGINX
### 11. Create Helm Chart
### 12. Deploy Helm Chart
