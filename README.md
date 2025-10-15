# marlboro

Configuration AWS CLI


Archi complète qui déploie :
	• VPC (multi-AZ) avec 2 subnets publics + 2 subnets privés, IGW, NAT, routage
	• Security Groups (bastion / app / db)
	• EC2 app (privé) + (optionnel) Bastion (public)
	• S3 (sécurisé, versioning + SSE)
	• RDS MySQL (privé, chiffré)
	• IAM Role pour l’EC2 (accès S3 en lecture)
	• Outputs utiles

Arborescence
aws-full-archi/
 ├── provider.tf
 ├── variables.tf
 ├── vpc.tf
 ├── security.tf
 ├── iam.tf
 ├── ec2.tf
 ├── rds.tf
 ├── s3.tf
 ├── outputs.tf

Exécution (ordre exact)
cd aws-full-archi
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply -auto-approve
terraform output

Nettoyage
terraform destroy -auto-approve

AWS Access Key ID [None]: XXXXXXXXXXXXXXXXX
AWS Secret Access Key [None]: XXXXXXXXXXXXXXXXX
Default region name [None]: eu-west-3
Default output format [None]: json

aws sts get-caller-identity

Commande	Description
terraform init	Initialise le projet (télécharge le provider AWS)
terraform fmt	Formate les fichiers .tf
terraform validate	Vérifie les erreurs de syntaxe
terraform plan	Montre ce que Terraform va créer
terraform apply	Crée les ressources (tu dois confirmer avec yes)
terraform show	Affiche l’état actuel
terraform destroy	Supprime toutes les ressources
terraform state list	Liste les ressources créées
terraform output	Affiche les outputs