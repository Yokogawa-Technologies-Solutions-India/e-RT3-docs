# Installing AWS IoT Greengrass V2 in Ubuntu

## Introduction

This article describes the steps to install the latest version of Greengrass, called Greengrass V2, which was released in December 2020. Greengrass V2 supports new features such as open-source edge runtime, improved modularity, command-line interface, and improved fleet development features. This enables you to develop, deploy, and manage IoT applications locally on your Edge device.

For details about installing Greengrass V1, refer to this [article](https://github.com/Yokogawa-Technologies-Solutions-India/e-RT3-docs/blob/master/Articles/AWS/Installing_AWS-IoT_Greengrass.md).

## Environment

**Supported devices (OS)**

- [e-RT3 Plus F3RP70-2L](https://www.yokogawa.com/solutions/products-platforms/control-system/ert3-embedded-controller/#Overview)（Ubuntu 18.04 32-bit) Edge controller of Yokogawa.
- Raspberry Pi 4 Model B （Ubuntu Server 20.04 32-bit）

The `armhf` architecture package runs on these devices.

## Getting started

To install AWS IoT Greengrass V2 you must complete the fllowing steps:

  1. [Install jdk packages on the Edge device](#installing-jdk-packages-on-the-edge-device)
  2. [Configure AWS authentication settings](#configuring-aws-authentication-settings)
  3. [Register IoT Core device on AWS and install core software in Edge device](#registering-iot-core-device-on-aws-and-installing-core-software-in-edge-device)

### Installing jdk packages on the Edge device

Run the following commands to install the required packages on the Edge device.

```bash
sudo apt update
sudo apt install unzip default-jdk
```

> **Note**: If the Edge device is in proxy environment, configuring [proxy settings](https://github.com/Yokogawa-Technologies-Solutions-India/e-RT3-docs/blob/master/Articles/Azure/Send-telemetry-data-from-e-RT3-to-azure-IoT-hub.md#proxy-settings) is mandatory.

### Configuring AWS authentication settings

Configure AWS authentication settings in the environment variables of Edge device. For details, refer to the [AWS authentication settings](https://docs.aws.amazon.com/greengrass/v2/developerguide/quick-installation.html#provide-installer-aws-credentials).

### Registering IoT Core device on AWS and installing core software in Edge device

Follow these steps to register an IoT Core device on AWS:

1. On the AWS IoT page, select **Greengrass devices**, and click **Set up one core** device.

    ![01_AWS_IOT](assets/01_AWS_IOT%20.png)

2. In the **Core device name** box, specify the name of the core device.

    ![02_RegisterGreenGrassDevice](assets/02_RegisterGreenGrassDevice.png)

3. Under **Thing group**, select **Enter a new group name**, and specify the name of the thing group in the **Thing group name** box.

    ![03_ConnectRemoteSystem.png](assets/03_ConnectRemoteSystem.png)

    >**Note**: If you want to add your core device to an existing thing group, select **Select an existing group**, and specify the name of the thing group  in the **Thing group name** box.

4. Download and install the core software in Edge device. Run the commands **1** and **2** in order in the Edge device to download and install the core software.

    ![04_DownloadandInstall](assets/04_DownloadandInstall.png)

    > **Note**: If the Edge device is in proxy environment, refer to [Installing core software in proxy environment](#installing-core-software-in-proxy-environment).

5. After the installation is complete, click **View core devices**.
    If the core device you created is displayed, registration and installation is successful. (It may take some time for the device to get displayed.)

    ![05_ViewcoreDevices](assets/05_ViewcoreDevices.png)

## Appendix

### Installing core software in proxy environment

If you want to operate your Edge device in a proxy environment, configuring proxy settings is mandatory. The settings may differ based on the operating environment. You can follow the following steps as a reference to configure proxy settings that are specific to your environment.

1. Create a core software settings file called `config.yaml` and configure the proxy settings as follows:

    ```bash
    config.yaml
    services:
        aws.greengrass.Nucleus:
            configuration:
                mqtt:
                    port: 443
                greengrassDataPlanePort: 443
                networkProxy:
                    proxy:
                        url: "http://username:password@xxx.com:port/"
    ```

2. In step 4 of the [Registering IoT Core device on AWS](#registering-iot-core-device-on-aws-and-installing-core-software-in-edge-device) procedure, in command **2**, delete `--deploy-dev-tools true` and add `--init-config (path/to/config.yaml)`.

    Modified command example:

    ```bash
    sudo -E java \
    -Droot="/greengrass/v2" -Dlog.store=FILE -jar ./GreengrassCore/lib/Greengrass.jar --aws-region ap-northeast-1 \
    --thing-name SampleCore --thing-group-name SampleCoreGroup --component-default-user ggc_user:ggc_group \
    --provision true --setup-system-service true --init-config (path/to/config.yaml)
    ```

    > **Note**: In a proxy environment, the option `--deploy-dev-tools true` is deleted as it will lead to deployment failure. If you want to deploy the CLI component manually, refer to [Deploying Greengrass CLI](#deploying-greengrass-cli).

### Deploying Greengrass CLI

[Greengrass CLI](https://docs.aws.amazon.com/greengrass/v2/developerguide/greengrass-cli-component.html) is the command-line interface (CLI) that enables you to develop and debug an application locally in the Edge device. If you have not included the `--deploy-dev-tools true` option when installing the AWS Core software, the Greengrass CLI (aws.greengrass.Cli) component is not deployed.

To deploy the Greengrass CLI component manually, perform these steps:

1. On the left pane, select **Greengrass devices > Components**.

    ![06_GreengrassCLI_components](assets/06_GreengrassCLI_components.png)

2. On the Public components tab, select **aws.greengrass.cli**.

    The *aws.greengrass.cli* page appears.

3. Click **Deploy**.

    ![07_GreengrassCLI_deploy](assets/07_GreengrassCLI_deploy.png)

4. Select **Create new deployment** and click **Next**.

    ![08_GreengrassCLI_createDeployment](assets/08_GreengrassCLI_createDeployment.png)

5. On the *Specify target* page, perform these steps:
    1. In the Deployment information section, specify a name to identify the deployment.
    2. In the Deployment target section, select **Core device** as the Target type, and then specify the target name in the **Target name** box.
    3. Click **Next**.

        ![09_GreengrassCLI_specifyTarget](assets/09_GreengrassCLI_specifyTarget.png)

6. From the Public components list, select the **aws.greengrass.Cli** check box and click **Next**.

    ![10_GreengrassCLI_PublicComponents](assets/10_GreengrassCLI_PublicComponents.png)

7. Verify the component and advanced deployment configurations, and click **Deploy**.

    ![11_GreengrassCLI_FinalDeploy](assets/11_GreengrassCLI_FinalDeploy.png)

    The *Deployment* page appears, displaying the deployment status as "Completed"

    ![12_GreengrassCLI_FinalDeployResult](assets/12_GreengrassCLI_FinalDeployResult.png)

8. Run the following command in the Edge device.

    ```bash
    username@ubuntu:~$ /greengrass/v2/bin/greengrass-cli --version    
    ```

    If the following output is generated, Greengrass CLI is deployed successfully.

    ```bash
    Greengrass CLI Version: 2.1.0     
    ```

## References

1. [AI Platform for industries | Yokogawa Electric Corp.](https://www.yokogawa.com/solutions/products-platforms/control-system/ert3-embedded-controller/#Overview)
2. [Greengrass - AWS IoT Greengrass](https://docs.aws.amazon.com/greengrass/v2/developerguide/greengrass-cli-component.html)
