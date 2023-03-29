# Using Azure App Service to visualize Edge data sent to Azure IoT Hub

## Introduction

Azure IoT Runtime enables you to collect information and execute commands on Edge devices remotely. When installed on e-RT3 Plus, the features of both e-RT3 Plus and Azure Runtime Environment can be utilized to perform various operations.

This is part four of a five-part series that demonstrates how to use Azure Runtime Environment with e-RT3 Plus. The first two parts describe how to use Azure IoT Runtime environment to create and deploy Azure IoT Edge Python modules that read and upload data to an IoT Hub. In the first part we read data from a sample temperature module, in the second part we read data from an Analog Input Edge device.

- [Deploying a sample Python module on an Edge Device installed with Azure IoT Edge Runtime](https://github.com/Yokogawa-Technologies-Solutions-India/e-RT3-docs/blob/master/Articles/AzureIoTRuntimeEnvironment/Deploying_sample_Python_module.md)
- [Create an Azure IoT Edge Python module to gather data from an Edge device and transmit it to the IoT Hub](https://github.com/Yokogawa-Technologies-Solutions-India/e-RT3-docs/blob/master/Articles/AzureIoTRuntimeEnvironment/CreatePythonDataCollection_AzureIoT.md)

The third part describes creating and deploying an Azure IoT Edge Python module that writes data to an Edge device.

- [Create an Azure IoT Edge Python module that writes data to an Edge device](https://github.com/Yokogawa-Technologies-Solutions-India/e-RT3-docs/blob/master/Articles/AzureIoTRuntimeEnvironment/PythonWriteModule_AzureIoTRuntime.md)

In this article, we create a web application that visualizes the data received at the IoT Hub using Azure App Services.

![00_WebApp_Positioning](assets/00_WebApp_Positioning.png)

The ultimate goal for this article series is to demonstrate how to:

1. Create an Azure IoT Edge Python module to gather data, process it, and upload it to IoT Hub
2. Create an Azure IoT Edge Python module for writing data to an Edge device
3. Visualize the collected data using Azure App Service and Power BI.

This article is based on the Microsoft tutorial [Visualize real-time sensor data from your Azure IoT hub in a web application](https://learn.microsoft.com/en-us/azure/iot-hub/iot-hub-live-data-visualization-in-web-apps). For more information about installing and deploying Azure IoT Runtime environment, refer to [Deploying Azure Runtime Environment on e-RT3 Plus](https://github.com/Yokogawa-Technologies-Solutions-India/e-RT3-docs/blob/master/Articles/Local_blob_storage/Installing_Azure_Runtime_on_e-RT3.md).

## Hardware modules

The following table describes the hardware modules used in this article.

| Module | Description |
|---|---|
|e-RT3 Plus F3RP70-2L (CPU module, Ubuntu 18.04 32-bit)| e-RT3 Plus controls the complete module set. It accesses each module from the CPU module to read and write data.  The `armhf` architecture package runs on this device. |
| F3AD08-6R (Analog Input module)| The Analog Input module (AD module) converts the external analog data received to digital data. |
| F3DA04-6R (Analog Output module)| The Analog Output (DA module) module converts the digital data sent from the e-RT3 Plus to analog data. |
| F3BU05-0D (Base module)| This is the base for connecting each module. It takes care of the power supply and communication between the modules that are connected to it. |
| F3PU20-0S (Power module)| The Power module is connected on the Base module and is used for power supply.|

The module configuration and wiring is the same as described in the [previous article](https://github.com/Yokogawa-Technologies-Solutions-India/e-RT3-docs/blob/master/Articles/AzureIoTRuntimeEnvironment/PythonWriteModule_AzureIoTRuntime.md).

For more information on the hardware modules, refer to [this page](https://www.yokogawa.com/solutions/products-and-services/control/control-devices/real-time-os-based-machine-controllers/#Overview).

> **Note**: The IoT Edge module development and device operations are performed on Windows 10 using Google Chrome as the web browser.

## Prerequisites

Before trying to visualize the data in the IoT Hub using Azure App Service, you meet the following requirements:

1. Complete the steps mentioned in the articles [Create an Azure IoT Edge Python module to gather data from an Edge device and transmit it to the IoT Hub](https://github.com/Yokogawa-Technologies-Solutions-India/e-RT3-docs/blob/master/Articles/AzureIoTRuntimeEnvironment/CreatePythonDataCollection_AzureIoT.md) and [Create an Azure IoT Edge Python module that writes data to an Edge device](https://github.com/Yokogawa-Technologies-Solutions-India/e-RT3-docs/blob/master/Articles/AzureIoTRuntimeEnvironment/PythonWriteModule_AzureIoTRuntime.md).
2. Install [Git for Windows](https://git-scm.com/) on your computer as Git is used in the deployment of the web application.

## Workflow

To create a web application that visualizes the data received at the IoT Hub using Azure App services, we must complete the following steps:

   1. [Adding a consumer group to the IoT Hub](#adding-a-consumer-group-to-the-iot-hub)
   2. [Obtaining the IoT Hub service connection string](#obtaining-the-iot-hub-service-connection-string)
   3. [Creating web application](#creating-web-application)
   4. [Deploying a web application](#deploying-a-web-application)
   5. [Verifying data visualization in the web application](#verifying-data-visualization-in-the-web-application)

## Adding a consumer group to the IoT Hub

Adding a consumer group to the IoT hub endpoint to enables the web application to read data from it.

Follow these steps to add a consumer group to the IoT Hub:

1. Navigate to [Azure Portal](https://portal.azure.com/).
2. On the left pane, under the **Hub settings** category, click **Built-in endpoints**.

   The *Built-in endpoints* page appears.
   ![01_ConsumerGroupSettings](assets/01_ConsumerGroupSettings.png)
3. In the **Consumer Groups** section, create a consumer group.
   > **Note**: Ensure that you save the name of the consumer group as you will need to use it later.

## Obtaining the IoT Hub service connection string

The service connection string provides the required permissions for a service to read and write data to the IoT Hub's endpoints.

Follow these steps to obtain the service connection string for your IoT Hub:

1. Navigate to [Azure Portal](https://portal.azure.com/).
2. On the left pane, under the **Security settings** category, click **Shared access policies**.

    The *Shared access policies* page appears.

   ![02_ConnectionString](assets/02_ConnectionString.png)

3. Under the **Manage shared access policies** section, click **iothubowner**.

    The *iothubowner* pane appears, displaying the Primary and secondary connection strings.
4. Copy either the **Primary connection string** or **Secondary connection string**.
   > **Note**: Ensure that you save the connection string as you will need to use it later.

## Creating web application

To create a web application using Azure App Service, we must complete the following steps:

1. [Create App Service resource](#creating-app-service-resource)
2. [Configure App Service settings](#configuring-app-service-settings)
3. [Modify web application code](#modifying-web-application-code)

### Creating App Service resource

Follow these steps to create an App service resource:

1. Navigate to [Azure Portal](https://portal.azure.com/).
2. In the upper left corner of the page, click **Create a resource**.
   ![03_CreateWebApp](assets/03_CreateWebApp.png)
3. Select **Web App**.

   The *Create Web App* page appears.
   ![04_SpecifydetailsWebApp](assets/04_SpecifydetailsWebApp.png)
4. Configure the mandatory parameters as described in the following table.

    | Parameter| Value |
    | --- | --- |
    | Project details - Subscription| Select an existing subscription |
    | Project details - Resource Group| Create a new Resource Group or select an existing Resource Group |
    | Instance details - Name| Specify any name |
    | Instance details - Publish| Select **Code** |
    | Instance details - Runtime stack*| Specify **Node 16 LTS** |
    | Instance details - Operating System| Select **Windows** |
    | Instance details - Region| Select region |
    | App Service Plan - Windows Plan (\<region name>)| Create a new plan or select an existing plan. |
    | App Service Plan - SKU| Select any item as necessary |
    | App Service Plan - Size| Select any item as necessary |

    `*` - Since the web application is created based on the sample described in [Visualize real-time sensor data from your Azure IoT hub in a web application](https://learn.microsoft.com/en-us/azure/iot-hub/iot-hub-live-data-visualization-in-web-apps), select **Node 16 LTS** for runtime stack.

5. Click **Review + create**.
6. After verifying the configured information, click **Create**.
   A message is displayed indicating that the App Service is deployed.

### Configuring App Service settings

After creating the App Service resource, we must configure it.

Follow these steps to configure the settings of the App Service:

1. Navigate to [Azure Portal](https://portal.azure.com/).
2. Select **App Services**, and then select your app.
3. On the left pane, under the **Settings** category, select **Configuration**.

    The *Configuration* page appears.
    ![041_Configuration](assets/041_Configuration.png)

4. In the **Application settings** tab, click **+ New application setting** and perform these steps:

    ![05_ConfigureSettings](assets/05_ConfigureSettings.png)
   1. Add the application settings described in the following table.

        |Name| Value| Deployment slot and settings|
        |---|---|---|
        |EventHubConsumerGroup| Specify the consumer group name created in [Adding a consumer group to the IoT Hub](#adding-a-consumer-group-to-the-iot-hub)| Empty|
        |IotHubConnectionString| Specify the IoT Hub connection string obtained in the [previous step](#obtaining-the-iot-hub-service-connection-string)|Empty|

   2. Verify the added settings and click **Save**.

        The settings are applied.
        > **Note**: If a dialog box appears, click **Continue**.

5. Click the **General settings** tab and specify the following details.

    ![06_AppSettingsModifyAdd](assets/06_AppSettingsModifyAdd.png)
   1. From the **HTTP version** drop-down list, select **2.0**.
   2. Select **On** for the **Web sockets** configuration.
   3. Click **Save**.

6. On the left pane, under the **Deployment** category, click **Deployment Center**.
    ![07_GitURIClone](assets/07_GitURIClone.png)

7. In the **Settings** tab, from the **Source** drop-down list, select **Local Git** and click **Save**.

    The **FTPS credentials** tab changes to **Local Git/FTPS credentials**.
    ![08_FTPSCredentialInfo](assets/08_FTPSCredentialInfo.png)
8. Click the **Local Git/FTPS credentials** tab.

    The **Git Clone Uri** is displayed in the **Local Git** section. Since this is required when you deploy the web application, copy and save it for future use.

9. In the **User scope** section, specify the **Username**, **Password** and **Confirm Password**. These credentials will be required when you deploy the web application.

   ![09_AccountInfo](assets/09_AccountInfo.png)
   >**Note**: You can also change the username and password in this User scope section.

10. Click **Save**.

### Modifying web application code

The web application is created based on the sample code described in the tutorial [Visualize real-time sensor data from your Azure IoT hub in a web application](https://learn.microsoft.com/en-us/azure/iot-hub/iot-hub-live-data-visualization-in-web-apps).

> **Note**: In this demonstration, we have used the code with the tag number `193943`.

Follow these steps to modify the web application code:

1. Run the following commands to clone the [sample code](https://github.com/Azure-Samples/web-apps-node-iot-hub-data-visualization) with tag number `193943` and create a branch.

    ```bash
    git clone https://github.com/Azure-Samples/web-apps-node-iot-hub-data-visualization.git -b 193943
    cd web-apps-node-iot-hub-data-visualization
    git branch master
    git checkout master
    ```

    The license is available [here](https://github.com/Azure-Samples/web-apps-node-iot-hub-data-visualization/blob/master/LICENSE).

    > **Note**: If your computer is in an environment that requires proxies to connect to the internet, configure the system environment variables as described [here](#proxy-settings).

2. Open the `web-apps-node-iot-hub-data-visualization` folder in Visual Studio Code and edit following files:

   - **`public/index.html`**
  
        Edit the title of the chart as follows:

        ```html
        <!-- Line 14 -->
        <title>e-RT3 Plus &amp; AD08 Real-time Data</title>

        <!-- Line 23 -->
        <span>e-RT3 Plus & AD08 Real-time Data</span>
        ```

   - **`public/js/chart-device-data.js`**
  
        The sample code is configured such that the temperature and humidity data collected from the sample module is represented on the vertical axis of the chart.

        We modify it such that data from channel 1 and 2 of the Analog Input module is represented on the vertical axis of the chart.

        Replace the parameters in the file `public/js/chart-device-data.js` according to the following table.

        |Existing parameter|Modified value|
        |---|---|
        |temperatureData|ch1Data|
        |humidityData|ch2Data|
        |temperature, Temperature, Temperature (ºC)|ch1|
        |humidity, Humidity, Humidity(%)|ch2|

   - **`scripts/event-hub-reader.js`**

        The sample code is configured such that the date and time at which the IoT Hub received telemetry data is represented on the horizontal axis of the chart.

        We modify it such that the date and time at which the Python IoT Edge data collection module fetches the channel data is represented on the horizontal axis of the chart.
  
        Modify the file `scripts/event-hub-reader.js` as follows:

        ```javascript
        // Line 28
        events[i].body.datetime,
        ```

## Deploying a web application

Follow these steps to deploy the web application:

1. Open Visual Studio Code.
2. From the Menu bar, select **View > Terminal** to open the terminal.
   > **Note**: Ensure that the current working directory in the terminal is `web-apps-node-iot-hub-data-visualization`.
3. Run the following commands to save the code changes to the local repository.

    ```bash
        git add
        git commit
    ```

4. Run the following command to add the remote repository.

   ```bash
   git remote add webapp <Git_Clone_URI>
   ```

    Here, `Git_Clone_URI` is the URI obtained in step 8 of [Configuring App Service settings](#configuring-app-service-settings).

5. Run the following command to push the web application to the remote repository.

    ```bash
    git push webapp master:master
    ```

    If the operation is completed, the following messages are displayed on the terminal. This operation usually takes a while to execute.

    ```bash
    remote: Deployment successful.
    To ＜Git clone URI＞
   * [new branch] master -> master
    ```

6. Navigate to [Azure Portal](https://portal.azure.com/).
7. On the left pane, under the **Deployment** category, click **Deployment Center**.

   The *Deployment Center* page appears.
   ![10_Deploy](assets/10_Deploy.png)
8. Select the **Logs** tab and verify whether the web application has been pushed.
9. If the web application is successfully deployed, on the left pane, click **Overview** and then click **Start** to start the web application.
   ![11_VerifyDeploy](assets/11_VerifyDeploy.png)

## Verifying data visualization in the web application

After starting the web application, you can open it by using the URL that is displayed on the same page.

![11_1_URLDeploy](assets/11_1_URLDeploy.png)

The data collected by the IoT Edge module is displayed in real time.

The following figure shows the chart displayed when the data is sent every 2 seconds.

![13_Twoseconds](assets/13_Twoseconds.png)

You can also modify the data collection interval for the Module Twin and observe the corresponding changes in the chart. The procedure to modify the interval for a Module Twin is described [here](https://github.com/Yokogawa-Technologies-Solutions-India/e-RT3-docs/blob/master/Articles/AzureIoTRuntimeEnvironment/CreatePythonDataCollection_AzureIoT.md#update-module-twin-and-verify-operation).

The following figure shows the chart displayed when the data is sent every 5 seconds.

![14_Fiveseconds](assets/14_Fiveseconds.png)

> **Note**: Since this URL can be accessed by anyone who has the link, you must stop the web application after confirming the operation.

## Conclusion

The data sent to IoT Hub by the Azure IoT Edge data collection module is visualized by using an Azure App Service web application. In the next article, we will use Power BI to visualize this data.

## Appendix

### Proxy settings

If your computer is in an environment that requires proxies to connect to the internet, you must add the HTTPS_PROXY to the system environment variables in your computer.

Follow these steps to add the HTTPS_PROXY to the system environment variables in your computer:

1. Click the Start icon and search for `System environment variables`.
2. From the search results, select "Edit the system environment variables".

    The *System Properties* dialog box appears.
3. Click **Environment Variables...**.

    The *Environment Variables* dialog box appears.
4. In the **System variables** section click **New...**.

    The *New System Variable* dialog box appears.
    ![37_EnVariable](assets/SystemVariableProxy.png)

5. Specify the **Variable name** and **Variable value** as described in the following table and then click **OK**.

    |Item name| Setting information|
    |---|---|
    |Variable name|HTTPS_PROXY|
    |Variable value|`http://username:password@example.com:port/`|
The HTTPS_PROXY is added to the system environment variables in your computer.
    

## References

1. [Real-time OS controller e-RT3 Plus F3RP70-2L](https://www.yokogawa.com/solutions/products-and-services/control/control-devices/real-time-os-based-machine-controllers/#Overview)
2. [Azure Certified Device catalog](https://devicecatalog.azure.com/)
3. [Visualize real-time sensor data from your Azure IoT hub in a web application](https://learn.microsoft.com/en-us/azure/iot-hub/iot-hub-live-data-visualization-in-web-apps)
4. [Tutorial: Visualize real-time sensor data from Azure IoT Hub using Power BI](https://learn.microsoft.com/en-us/azure/iot-hub/iot-hub-live-data-visualization-in-power-bi)
