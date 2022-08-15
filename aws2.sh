echo "Setting up AWS v2"

echo "Downloading AWS CLI v2 package..."
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "/tmp/AWSCLIV2.pkg"

echo "Run AWS CLI V2 Installer..."
sudo installer -pkg /tmp/AWSCLIV2.pkg -target /

echo "Directory $(which aws)"

echo "Verifying successful installation..."
aws --version
