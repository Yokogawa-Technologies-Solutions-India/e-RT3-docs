# Installing AWS IoT Greengrass on e-RT3 Plus

## Introduction

AWS IoT Greengrass is a software that renders enhanced cloud capabilities to field devices. This enables the devices to collect and analyze data locally, react to local events independently, and communicate securely on local networks. The devices can also communicate securely with AWS IoT Core and export IoT data to the AWS Cloud.

In this article, we will create a Greengrass Group on AWS Cloud and install AWS IoT Greengrass Core on the Edge device (e-RT3 Plus). Additionally, we will deploy a sample package to verify the connection with AWS Cloud.

For more information on AWS IoT Greengrass, refer to [AWS IoT Greengrass official website](https://docs.aws.amazon.com/greengrass/index.html).
[Azure IoT Edge](https://github.com/Yokogawa-Technologies-Solutions-India/e-RT3-docs/blob/master/Articles/Azure/Send-telemetry-data-from-e-RT3-to-azure-IoT-hub.md) article is also available for your reference.

## Environment

- e-RT3 Plus F3RP70-2L（Ubuntu 18.04 32-bit）
This is the Edge controller of Yokogawa Electric Corporation. It is registered in the AWS IoT Greengrass.
- Raspberry Pi 4 Model B （Ubuntu Server 20.04 32-bit)

> **Note**: These devices can execute `armhf` architecture packages.


## Preparation

### Creation of AWS account

If you do not have an AWS account, create one using this [link](https://aws.amazon.com/en/).

Limited usage slots are available for free.
For more information on using free slots, click [here](https://aws.amazon.com/free/?nc2=h_ql_pr_ft&all-free-tier.sort-by=item.additionalFields.SortRank&all-free-tier.sort-order=asc&awsf.Free%20Tier%20Categories=categories%23iot&awsf.Free%20Tier%20Types=*all).

### Installation of WinSCP

Transferring files from PC to the device requires installation of WinSCP.

For more information on installing and using WinSCP, refer to the [official website](https://winscp.net/eng/index.php).

### Installation of Python3.8

> **Note**: This setting is required only when using e-RT3. When using e-RT3, [sudo setting](https://github.com/Yokogawa-Technologies-Solutions-India/e-RT3-docs/blob/master/Articles/Azure/Send-telemetry-data-from-e-RT3-to-azure-IoT-hub.md#enabling-sudo-user) is required for common users to use the *sudo* command.

1. Run the following commands to install Python3.8 to be used in Lambda of Greengrass.

    ```bash
    sudo apt update
    sudo apt install python3.8
    ```

2. To confirm whether installation is successful, run the following command to check the version.

    ```bash
    username@ubuntu:~$ python3.8 --version
    Python 3.8.0
    ```

### Installation of Java8

Java8 is required for using the Stream Manager of Greengrass.

1. To install Java8, run the following commands:

    ```bash
    sudo apt update
    sudo apt install openjdk-8-jdk
    ```

2. To establish the connection, run the following command:

    ```bash
    sudo ln /etc/alternatives/java /usr/bin/java8
    ```

3. To verify if Java8 is installed properly, run the following commands:

    ```bash
    username@ubuntu:~$ java8 -version
    openjdk version "1.8.0_292"
    OpenJDK Runtime Environment (build 1.8.0_292-8u292-b10-0ubuntu1~18.04-b10)
    OpenJDK Client VM (build 25.292-b10, mixed mode)
    ```

### Validating cgroup

> **Note**: This setting is required only when using Raspberry Pi.

Validate cgroup for running Lambda in the container.

1. Open `/boot/firmware/cmdline.txt`.

    ```bash
    sudo vi /boot/firmware/cmdline.txt
    ```

2. Add the following value to the end of the existing row.

    ```bash
    cgroup_enable=memory cgroup_memory=1
    ```

3. Restart the device.

    ```bash
    sudo reboot
    ```

----

## Creating Greengrass Group

Follow these steps to create a Greengrass Group in AWS Cloud:

1. In the upper-right corner of the *AWS Management Console* page, select your region from the menu bar.

    ![AWS_managementConsole](assets/AWS_managementConsole.jpg)

2. On the menu bar, click the **Service** menu, and in the **Search** box, type `iot greengrass`.

    From the list of services that appear, select IoT Greengrass.

    ![AWS_managementConsole_search](assets/AWS_managementConsole_search.jpg)

3. On the navigation pane, expand **Greengrass > Classic (V1)** and select **Groups**, and then click **Create Group** on the right pane.
    ![AWS_managementConsole_CreateGroup](assets/AWS_managementConsole_CreateGroup.jpg)

4. Click **Use default creation**.
    ![AWS_managementConsole_useDefault](assets/AWS_managementConsole_useDefault.jpg)
5. In the **Group Name** box, type your group name and click **Next**.
    ![AWS_managementConsole_Groupname](assets/AWS_managementConsole_Groupname.jpg)
6. In the **Name** box, type the name of the Greengrass Core for the group and click **Next**. By default, “_Core” is appended with the group name.

    ![AWS_managementConsole_nameCore](assets/AWS_managementConsole_nameCore.jpg)

7. Click **Create Group and Core**.
    ![AWS_managementConsole_CreateCore](assets/AWS_managementConsole_CreateCore.jpg)

8. Click **Download these resources as tar.gz** to download the security resource for connecting the device to the cloud.

    ![AWS_managementConsole_Download](assets/AWS_managementConsole_Download.jpg)

    >**Note**: that this file cannot be downloaded later and hence, you must download the file before proceeding to the next step.

9. After downloading the file, click **Finish**.
    The Greengrass Group is created.

## Installing Greengrass Core on e-RT3 Plus

There are several methods to install Greengrass Core on the e-RT3 Plus device.
In this exercise, we will install Greengrass Core from the APT repository.

>**Note**: Installing Greengrass Core from APT repository does not support OTA updates. Follow other installation methods if you want to use OTA updates.

To install Greengrass Core, we will first configure the security settings on the e-RT3 Plus device.

### Configuring security settings on e-RT3 Plus

Let us install the security resources and CA certificates on the e-RT3 Plus device. This is required to connect the device to AWS Cloud.

#### Installing security resources

1. Open WinSCP and connect to the device by logging on to the e-RT3 terminal.
    ![AWS_Winscp](assets/AWS_Winscp.jpg)

2. Copy the security resource (tar.gz file), which you downloaded while creating Greengrass Group, to the e-RT3 terminal in WinSCP.

3. Run the following command and install the security resource. Replace the {hash} part to match the file name of the security resource.

    ```bash
    sudo mkdir -p /greengrass
    sudo tar -xzvf ~/{hash}-setup.tar.gz -C /greengrass
    ```

#### Downloading root CA certificate

1. Move to `/greengrass/certs`.

    ```bash
    cd /greengrass/certs/
    ```

2. Download the Amazon Root CA 1 certificate with the name `root.ca.pem`.

    ```bash
    sudo wget -O root.ca.pem https://www.amazontrust.com/repository/AmazonRootCA1.pem
    ```

Ensure that the downloaded `root.ca.pem` file is not empty (downloaded correctly). If the file is empty, try downloading again.

```bash
cat root.ca.pem
```

### Installing Greengrass Core software

1. Create system account for Greengrass.

    ```bash
    sudo adduser --system ggc_user
    sudo addgroup --system ggc_group
    ```

2. Install AWS IoT Greengrass keyring package and add repository.

    ```bash
    cd ~
    sudo wget -O aws-iot-greengrass-keyring.deb https://d1onfpft10uf5o.cloudfront.net/greengrass-apt/downloads/aws-iot-greengrass-keyring.deb
    sudo dpkg -i aws-iot-greengrass-keyring.deb
    username@ubuntu:~$ echo "deb https://dnw9lb6lzp2d8.cloudfront.net stable main" | sudo tee /etc/apt/sources.list.d/greengrass.list
    deb https://dnw9lb6lzp2d8.cloudfront.net stable main
    ```

3. Update package list and install Greengrass Core software.

    ```bash
    sudo apt update
    sudo apt install aws-iot-greengrass-core
    ```

4. Start Greengrass Demon.

    ```bash
    sudo systemctl start greengrass.service
    ```

    Run the following commands to check if Demon is running correctly. (If the displayed `Active` status is `active(running)`, it means that Demon is running.)

    ```bash
    username@ubuntu:~$ systemctl status greengrass.service
    * greengrass.service - Greengrass Daemon
    Loaded: loaded (/lib/systemd/system/greengrass.service; disabled; vendor preset: enabled)
    Active: active (running) since Fri 2021-03-05 06:31:07 UTC; 14min ago
    Process: 2159 ExecStart=/greengrass/ggc/core/greengrassd start (code=exited, status=0/SUCCESS)
    Main PID: 2163 (5)
    Tasks: 10 (limit: 2366)
    CGroup: /system.slice/greengrass.service
    ```

    To start the software automatically when the device is started, run the following command:

    ```bash
    sudo systemctl enable greengrass.service
    ```

> **Note**: If the device is in a proxy environment, [proxy settings](#proxy-settings) must be configured.

## Deployment

Now we will deploy a sample package to check if the device is connected to AWS Cloud.

Follow these steps to test the connection in AWS Greengrass:

1. On the navigation plane, select **Groups**, and click the created group.
   ![AWS_Deployment_Groups](assets/AWS_Deployment_Groups.jpg)
2. From the **Actions** menu, click **Deploy** to deploy the group.
    ![AWS_Deployment_Actions](assets/AWS_Deployment_Actions.jpg)
3. Click **Automatic detection**.
    ![AWS_Deployment_automaticDetection](assets/AWS_Deployment_automaticDetection.jpg)
4. Wait for a few minutes until the deployment is complete.

    If the group is deployed successfully, the connection status is displayed in green.
    ![AWS_Deployment_Result](assets/AWS_Deployment_Result.jpg)

## Summary

As demonstrated in this article, it is easy to install and run AWS IoT Greengrass on e-RT3 Plus. In the subsequent articles, we will explore further on deploying applications on e-RT3 Plus using AWS Cloud.

----

## Additional information

### Proxy settings

If the device is in proxy environment, configuring proxy setting is mandatory.
Although the settings differ based on environment, we will focus on configuring environment variables and Greengrass Core settings.

#### Configuring environment variables

Refer [this article](https://github.com/Yokogawa-Technologies-Solutions-India/e-RT3-docs/blob/master/Articles/Azure/Send-telemetry-data-from-e-RT3-to-azure-IoT-hub.md#proxy-settings) to configure environment variables.

#### Configuring Greengrass Core settings

Refer [this article](https://docs.aws.amazon.com/greengrass/v1/developerguide/gg-core.html) to configure Greengrass Core  settings and then perform these steps:

1. Stop Greengrass if it is already running.

    ```bash
    sudo systemctl stop greengrass.service
    ```

2. Add write permission to /greengrass/config/config.json and open.

    ```bash
    sudo chmod +w /greengrass/config/config.json
    sudo vi /greengrass/config/config.json
    ```

3. Add `iotMqttPort` object and `networkProxy` object to the `coreThing` object.

    The file after adding objects is shown below.

    ```bash
    /greengrass/config/config.json
    {
    "coreThing" : {
        "caPath" : "root.ca.pem",
        "certPath" : "3283c6f04d.cert.pem",
        "keyPath" : "3283c6f04d.private.key",
        "thingArn" : "arn:aws:iot:ap-northeast-1:xxxxxxxxxxxx:thing/eRT3Group_Core",
        "iotHost" : "xxxxxxxxxxxx-ats.iot.ap-northeast-1.amazonaws.com",
        "iotMqttPort" : 443,
        "ggHost" : "greengrass-ats.iot.ap-northeast-1.amazonaws.com",
        "keepAlive" : 600,
        "networkProxy":{
            "proxy":{
                "url" : "http://username:password@example.com:port/"
            }
        }
    },
    ...
    ```

4. Remove write permission for the file and start Greengrass once again.

    ```bash
    sudo chmod -w /greengrass/config/config.json
    sudo systemctl start greengrass.service
    ```

----

## References

1. [e-RT3 Products - CPU](https://www.yokogawa.com/solutions/products-platforms/control-system/ert3-embedded-controller/ert3-products/ert3-products-cpu/)
2. [AWS Partner Device Catalog](https://devices.amazonaws.com/)
3. [Configure AWS IoT Greengrass on AWS IoT](https://docs.aws.amazon.com/greengrass/v1/developerguide/gg-config.html)
4. [Install the AWS IoT Greengrass Core software from an APT repository](https://docs.aws.amazon.com/greengrass/v1/developerguide/install-ggc.html#ggc-package-manager)
5. [Connect on port 443 or through a network proxy](https://docs.aws.amazon.com/greengrass/v1/developerguide/gg-core.html#alpn-network-proxy)


