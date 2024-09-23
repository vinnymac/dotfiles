#!/usr/bin/env bash

echo "Setting up AWS v2"

# Check if we are using Apple Silicon
if [[ "$(uname -s)" = Darwin && "$(uname -v)" = *ARM64* ]]; then
    echo "Apple Silicon detected, attempting to build aws from source..."
    # see: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-source-install.html

    # Install AWS CLI v2 from source
    # Bash script to install the latest released version of the [AWS CLI v2](https://aws.amazon.com/cli/) from the distrubuted source.
    # Using this method to exectue the CLI under a MacBook M1 laptop as a native ARM binary - rather than falling back to [Rosetta](https://support.apple.com/en-au/102527). Currently the offically packaged macOS `.pkg` [doesn't support both Intel/M1 architectures](https://github.com/aws/aws-cli/issues/7252).
    # Script designed to be re-run - will blow away an existing install and re-install the latest available version.
    # > [!NOTE]
    # > This install script assumes you have installed a suitable version of [Python 3](https://www.python.org/downloads/) - has been tested against `Python 3.10.11` under macOS Sonoma `v14.6.1`.
    # ## Usage
    # ```sh
    # $ ./install.sh
    # $ which aws
    # /usr/local/bin/aws
    # $ which aws_completer
    # /usr/local/bin/aws_completer
    # $ aws --version
    # aws-cli/2.15.45 Python/3.10.11 Darwin/23.4.0 source-sandbox/arm64 prompt/off
    # ```
    # ## Related
    # - https://docs.aws.amazon.com/cli/latest/userguide/getting-started-source-install.html
    # - https://github.com/aws/aws-cli/issues/7252

    WORK_DIR=$(mktemp -d)

    # install virtualenv
    unset PIP_USER
    PIP_USER="1" pip3 install --user virtualenv --break-system-packages

    # download source package and un-tar
    curl --silent https://awscli.amazonaws.com/awscli.tar.gz | \
        tar --directory "$WORK_DIR" --extract --gzip

    pushd "$WORK_DIR"
    cd "$(ls -1)"

    # drop existing installed aws-cli, configure and install
    sudo rm -fr /usr/local/lib/aws-cli
    ./configure --with-download-deps
    make
    sudo make install
    popd

    # cleanup
    sudo rm -fr "$WORK_DIR"
else # Fallback to official package installation method
    echo "Downloading AWS CLI v2 package..."
    curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "/tmp/AWSCLIV2.pkg"

    echo "Run AWS CLI V2 Installer..."
    sudo installer -pkg /tmp/AWSCLIV2.pkg -target /

    echo "Directory $(which aws)"

    echo "Verifying successful installation..."
fi

aws --version
