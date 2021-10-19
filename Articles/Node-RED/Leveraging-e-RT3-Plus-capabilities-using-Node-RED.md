# Leveraging e-RT3 Plus capabilities using Node-RED

## Introduction

e-RT3 Plus is a versatile device that supports a variety of programming methods and tools. 

You can leverage the capabilities of e-RT3 Plus by using Node-RED to develop industrial-grade applications. This programming environment uses a browser-based editor and easy-to-assemble nodes to create logical flows. The Node-RED flow editor simplifies programming by using a visual coding process, thus allowing you to solely focus on the operation without getting into the details of the code.

In this article, we will demonstrate how to create a Node-RED flow for collecting, storing, and visualizing data using e-RT3 Plus. To create the flow, open source tools such as InfluxDB, Node-RED, and Grafana are used.

![Positioning](assets/node-red-1/positioning.png)

Node-RED is installed in e-RT3 Plus. InfluxDB and Grafana are installed on a server PC. Data sent to e-RT3 Plus is picked up by Node-RED. Node-RED then processes this data and writes it into InfluxDB. Grafana, which is connected to InfluxDB, processes the data and provides powerful data visualization features.

## Workflow

The following figure shows the workflow for collecting and visualizing data by using InfluxDB and Grafana with Node-RED.

![Workflow](assets/node-red-1/Workflow.png)

---

## Prerequisites

You must have a working knowledge of e-RT3 Plus components and setup, as well as a basic awareness of the different I/O modules used in this example.

Before you start creating a Node-RED flow, the following requirements must be met:

1. [Hardware wiring](#hardware-wiring) must be completed.
2. [InfluxDB and Grafana](#install-influxdb-and-grafana-on-the-server-pc) must be installed on the server PC.
3. [Node-RED and m3io nodes](#install-node-red-and-m3io-nodes) must be installed on e-RT3 Plus.
4. [InfluxDB nodes](#install-influxdb-nodes) must be installed on e-RT3 Plus.

>**Note**: InfluxDB and Grafana can also be installed on the e-RT3 Plus device separately.

For more information on how to install InfluxDB and Grafana on the e-RT3 Plus device, refer to the [Appendix](#appendix).

### Hardware wiring

![HardwareWiringDraw](assets/node-red-1/HardwareWiringDraw.png)

We will be using three I/O modules of the e-RT3 Plus device for this example.

- [**AD08**](https://www.yokogawa.com/solutions/products-platforms/control-system/ert3-embedded-controller/ert3-products/ert3-products-aio/#Details_Analog-Input-module) – This is a 16-bit or 12-bit analog to digital converter.
- [**DA04**](https://www.yokogawa.com/solutions/products-platforms/control-system/ert3-embedded-controller/ert3-products/ert3-products-aio/#Details_Analog-Output-module) – This is a 16-bit digital to analog converter.
- [**HA12**](https://www.yokogawa.com/solutions/products-platforms/control-system/ert3-embedded-controller/ert3-products/ert3-products-data-acquisition/) – This is a high-speed data acquisition module.

In this example, the AD08, DA04, and HA12 are configured as shown in the above diagram. Using this configuration, simulated data is generated for use.

>**Note**: The configuration described above serves as an example of a basic setup. Based on this understanding, a user can configure a similar setup to generate simulated data.

### Install InfluxDB and Grafana on the server PC

This section describes how to install InfluxDB and Grafana using Windows 10 as the server PC. You can also use any other system as the server PC.

For information on using other systems as server PCs, refer to [Docker's product documentation](https://docs.docker.com/engine/install/).

For information on how to install InfluxDB and Grafana on the server PC without using Docker, refer to the [InfluxDB](https://portal.influxdata.com/downloads/) and [Grafana](https://grafana.com/grafana/download?pg=get&plcmt=selfmanaged-box1-cta1) documentation.

Follow these steps to install InfluxDB and Grafana on your Windows 10 server PC by using Docker:

1. [Install Docker Engine](#install-docker-engine).
2. [Install InfluxDB with Docker](#install-influxdb-with-docker)
3. [Install Grafana with Docker](#install-grafana-with-docker)

#### Install Docker Engine

For information on how to install Docker on your system, refer to the [product documentation](https://docs.docker.com/engine/install/).

#### Install InfluxDB with Docker

Follow these steps to install InfluxDB with Docker:

>**Note**: If you are using a proxy, refer to the steps described in [Proxy settings for Docker](#proxy-settings-for-docker) and then continue.

1. Open Command Prompt on the server PC.
2. Run the following command to download the InfluxDB docker image from Docker hub.

    ```bash
    docker pull influxdb:1.8-alpine
    ```

3. Run the following command to create and start the InfluxDB container.

    ```bash
    docker run -d -p {INFLUXDB_PORT_NUMBER}:{INFLUXDB_PORT_NUMBER} -it --name {influxdb-container-name} influxdb:1.8-alpine
    ```

    >**Note**: Here, `{influxdb-container-name}` is the name specified for the InfluxDB container. The default port number is 8086.

Influx DB is installed.

You can use the following key commands to start and stop the InfluxDB container:

- To start.

   ```bash
   docker start {influxdb-container-name}
   ```

- To stop.

   ```bash
   docker stop {influxdb-container-name}
   ```

#### Install Grafana with Docker

Follow these steps to install Grafana with Docker:

1. Open  Command Prompt on the server PC.
2. Run the following command to download the Grafana docker image from Docker hub. 

    ```bash
    docker pull grafana/grafana:latest
    ```

3. Run the following command to start Grafana.

    ```bash
    docker run -d -p {PORT_NUMBER}:{PORT_NUMBER} -it --name {grafana-container-name} grafana/grafana:latest
    ```

    >**Note**: Here, `{grafana-container-name}` is the name specified for the Grafana container. The default {PORT_NUMBER} is 3000.

4. To open the created Grafana container, type the following URL in the address bar of your web browser.

    `http://localhost:{PORT_NUMBER}`

    >**Note**: The default port number is 3000.

Grafana is installed.

You can use the following key commands to start and stop the Grafana container:

- To start.

   ```bash
   docker start    {grafana-container-name}
   ```

- To stop.

   ```bash
   docker stop {grafana-container-name}
   ```

### Install Node-RED and m3io nodes

Follow these steps to install Node-RED and m3io nodes on the e-RT3 Plus device:

>**Note**: If you are using a proxy, refer to the proxy settings described in [Send telemetry data from e-RT3 Plus to Azure IoT hub](https://github.com/Yokogawa-Technologies-Solutions-India/e-RT3-docs/blob/master/Articles/Azure/Send-telemetry-data-from-e-RT3-to-azure-IoT-hub.md#proxy-settings).

1. Open an SSH terminal.
2. Run the following command to install Node.js.

    ```bash
    curl -fsSL https://deb.nodesource.com/setup_14.x | sudo -E bash -
    sudo apt-get install -y nodejs
    ```

    > **Note**: In this example, we will be using node version `Node.js LTS(v14.x)`.

3. Upload the .tgz files provided by Yokogawa to any directory in the e-RT3 Plus device by using WinSCP.

    Click [here](https://github.com/Yokogawa-Technologies-Solutions-India/e-RT3-docs/tree/master/Libraries/node-red) to download the .tgz files.

   For more information about how to transfer files to e-RT3 Plus using WinSCP, refer to [Using WinSCP to transfer files to e-RT3 Plus](https://github.com/Yokogawa-Technologies-Solutions-India/e-RT3-docs/blob/master/Articles/AI/Sample_AI_Application.md#using-winscp-to-transfer-files-to-e-rt3-plus).

4. Run the following command in the terminal to navigate to the folder where the .tgz files are copied.

    ```bash
    cd {TGZ_FOLDER_PATH}
    ```

    Here, TGZ_FOLDER_PATH, is the folder location of the .tgz files.
5. To complete the Node.js setup, perform these steps:

    1. Run the following command to locate the global `node_module` folder.

        ```bash
        npm list -g | head -1
        ```

        The default path of the `node_module` folder is `/usr/lib`.

    2. Edit the `/etc/environment` file to add the following line.

        ```bash
        NODE_PATH="{node_module_directory}/node_modules:"
        ```

        Here, `{node_module_directory}` is the path of the `node_module` folder obtained from the previous step.

    3. The environment must be reloaded to reflect the changes to the environment variables. Run the following command to reload the environment:

        ```bash
        source /etc/environment
        ```

6. Run the following command to install Node-RED and m3io globally.

    ```bash
    sudo npm install -g --unsafe-perm node-red@1.2.9 m3io_nodejs-1.0.0.tgz
    ```

    >**Note**: If you are using a proxy, refer to the proxy settings described in the [Appendix](#proxy-settings-for-npm).

    >**Note**: To use the latest version of Node-RED, refer to the [changelog](https://github.com/node-red/node-red/blob/master/CHANGELOG.md) and adapt any changes while performing the steps accordingly.

7. Run the following command to update the m3io settings in Node-RED.

   ```bash
    sudo tar -xf node_red_settings.tgz --directory /
    ```

    The `/node_red` folder is created in the root directory.

8. Run the following command to add the m3io nodes.

    ```bash
    sudo tar -xf m3io_nodered-1.0.0.tgz --directory /node_red
    ```

    The `m3io_node` folder is created in the `node_red` directory.

9. After installing the m3io nodes, run the following commands to start Node-RED.

    ```bash
    sudo systemctl enable node-red.service
    sudo systemctl start node-red.service
    ```

10. Once Node-RED is started, open a web browser of your choice, and type the following URL in the address bar to open the Node-RED editor.  
    `http://{IP_ADDRESS_OF_ERT3}:{PORT_NUMBER}`  

    Here, {PORT_NUMBER} is the configured port number for communication with e-RT3 Plus. The default port number is 1880.

    {IP_ADDRESS_OF_ERT3} can be determined by running the following command in the terminal.

    ```bash
    hostname -I
    ```

    The *Login* page of the Node-RED editor window appears.  

    >**Note**: If any error occurs, install the [node-red-dashboard](https://flows.nodered.org/node/node-red-dashboard) and try again.

11. Specify the login credentials. 

    By default the username is `admin`, and password is `ert3_admin`.

    >**Note**: To modify the default login configuration, refer to the [official documentation](https://nodered.org/docs/user-guide/runtime/securing-node-red#usernamepassword-based-authentication).
12. Click **Login**.
    The Node-RED editor page appears.

### Install InfluxDB nodes

Follow these steps to install InfluxDB nodes:

1. Open the Node-RED editor.
2. In the upper-right corner, select **Menu > Manage** palette.
    ![Manage Palette](assets/node-red-1/MicrosoftTeams-image-ManagePallete.png)

3. In the dialog box that appears, on the left pane, click the **Palette** tab, and then click the **Install** tab.
    ![Install influxDB nodes](assets/node-red-1/MicrosoftTeams-image-Manage_Pallete.png)

4. In the **Search** box, type `node-red-contrib-influxdb`.

    The search results appear.

5. Click **Install** to install the InfluxDB nodes.

    InfluxDB nodes are installed.

---

## Getting Started

After we have set up the system and met the requirements, we can start configuring the system to collect data and display it on Grafana. This can be achieved by completing the following steps:

1. [Create a database in InfluxDB](#create-influxdb-database)
2. [Create a Node-RED flow](#create-node-red-flow)
3. [Connect Grafana to InfluxDB](#connect-grafana-to-influxdb)
4. [Configure Grafana to display the data](#configure-grafana-to-display-the-data)

### Create InfluxDB database

Follow these steps to create the InfluxDB database:

1. Open command prompt on the server PC.
2. Run the following command to start the InfluxDB container.

    ```bash
    docker exec -it {influxdb-container-name} sh
    ```

    Here `{influxdb-container-name}` is the name given to the created InfluxDB container.

    >**Note**: Type `exit` to exit the container.
3. Run the following command to connect automatically to the InfluxDB instance.

    ```bash
    influx
    ```

4. Run the following command to create a database.

    ```bash
    CREATE DATABASE <db-name>
    ```

    Here, `db-name` is the name of the database that you want to create.

### Create Node-RED flow

At this point, your system components have been installed, your database is running, and you have access to the Node-RED editor. Now, we will demonstrate the use of the Node-RED editor to create a simple flow that captures input data from the AD08 module and writes it into the InfluxDB database.

By using Node-RED’s characteristically intuitive and easy programming interface along with e-RT3 Plus, you can quickly develop flows to suit your requirements. Yokogawa has developed custom m3io nodes to be used in the Node-RED flows. These can be used in very much the same way as the standard Node-RED widgets.  For this example, we will be using the readM3IoRegister custom node.

Follow these steps to create a simple Node-RED flow that reads data and writes it to the database:

1. Open the Node-RED editor.
2. On the left pane, select the **inject** node and drag it onto the workspace. This node will inject the data at a specified time interval.
    ![inject node](assets/node-red-1/inject-node.PNG)

3. Double-click the created node and configure the properties to read data every five seconds.
4. In the upper-right corner of the *Properties* page, click **Done**.
5. On the left pane, select the **readM3IoRegister** node and drag it onto the workspace. This node will read data from the AD08 registers.  
    ![m3io nodes](assets/node-red-1/read-node.PNG)
6. Double-click the created node and configure its properties as necessary.

    >**Note**: In this example, according to our hardware configuration, the data is read from the register positions 2 and 3 in the AD08 module, which is located in slot 4. Therefore, **Slot** and **Position** is specified as 4 and 2 respectively. However, you must verify the slot location and positions from the Web Maintenance Tool before specifying the values.

    To learn how to connect to the Web Maintenance Tool, refer to [Remote Communication with e-RT3 Plus](https://github.com/Yokogawa-Technologies-Solutions-India/e-RT3-docs/blob/master/Articles/e-RT3/Communication-with-e-RT3-Plus.md).

7. Create another **readM3IoRegister** in the same way, but this time, specify the position as 3.

    >**Note**: Again, the position must be verified from the Web Maintenance Tool and specified accordingly.
8. Now that we have read the data, we must create a node to write this data into the database. On the left pane, select the **influxdb out** node and drag it onto the workspace. 
![influx db widget](assets/node-red-1/influx2.PNG)

9. Double-click the created node and configure its properties as necessary.

    >**Note**: The database name must match the name specified while creating the InfluxDB database,  the time precision must be in seconds, and the server URL must be `http://{SERVER_PC_IP_ADDRESS}:{PORT_NUMBER}`. Here, {SERVER_PC_IP_ADDRESS} is the IP address of the server PC, and {PORT_NUMBER} is the configured port. The default port number is 8086.

     ![configure db properties](assets/node-red-1/influx1.PNG)

10. On the left pane, select the **debug** node and drag it onto the workspace. This node will verify the values that are being received. Edit the properties of the node as necessary.
11. Use connectors to connect all the nodes. The following figure shows the final flow to be created.
    ![Final flow](assets/node-red-1/flow.PNG)

12. On the menu bar, click **Deploy** to activate the flow.
13. To start the flow, click the **Inject** button. This will start injecting the data into the flow.
14. In the upper-right corner of the Node-RED editor window, click the **Debug** tab.

    ![Final flow](assets/node-red-1/debugtab.PNG)

The debug pane appears, displaying the values being read every five seconds.

### Connect Grafana to InfluxDB

Now that we have data being written into the database, we can link InfluxDB and Grafana. This will allow Grafana to access the data written in InfluxDB. Grafana uses this data and provides you with a powerful interface to visualize this data.

Follow these steps to connect Grafana to InfluxDB:

1. To open Grafana, type the following URL in the address bar of your web browser.

     `http:// {IP_ADDRESS_OF_SERVER}:{PORT_NUMBER}`

     >**Note**: The default port number is 3000.

2. On the *login* page, enter the login credentials.

    >**Note**: For both username and password, the default value is "admin".
3. Click **Log In**.
4. In the upper-left corner, click the Grafana icon to open the side menu.
5. From the side menu, click the **Settings** icon, and select **Configuration > Data Sources**.
6. On the page that appears, click **Add data source**.
    ![Add data source](assets/node-red-1/Add_data_source.png)

7. From the list that appears, select **InfluxDB**.
    ![Add data source](assets/node-red-1/grafana-searchbox.png)
    The *Settings* page appears.

    Alternatively, you can use the Search box to locate InfluxDB.
8. On the *Settings* page, specify the necessary details.
![Add data source](assets/node-red-1/InfluxDBsettings.png)
The following table describes the values to be specified in the corresponding fields on the *Settings* page.

    **Name        :** Provide a suitable name for the data source.

    **URL         :** `http://{IP_ADDRESS_OF_SERVER}:{PORT_NUMBER}`

    **Database    :** The database name specified while [creating the InfluxDB](#create-influxdb-database) database.

9. Click **Save + Test**.
    ![Add data source](assets/node-red-1/grafana-save-and-test.png)

For more information about using InfluxDB in Grafana, refer to the [product documentation](https://grafana.com/docs/grafana/latest/datasources/influxdb/).

### Configure Grafana to display the data

Once Grafana is connected to InfluxDB, we can move forward with displaying the data written in InfluxDB. 
Follow these steps to visualize InfluxDB data on Grafana:

1. In the Grafana window, on the left pane, click the **+** icon and select **Dashboard**.
2. Click **Add new panel**.
3. In the lower-left corner, click the **Query** tab.
    ![grafana-dasahboard](assets/node-red-1/dashboard.png)

4. In the form that appears, select the parameter to be visualized.

    You can also customize the appearance by using controls that are available on the right pane.
5. In the upper-right corner, click **Save** and then click **Apply**.
    ![visualize data](assets/node-red-1/dashboard1.png)
The data from the InfluxDB appears according to the configured visualization settings.

You can also add additional panes as well as measurements that can be displayed simultaneously.
Additionally, Grafana can be configured to display the data in real time.

For more information about using InfluxDB in Grafana, refer to the [product documentation](https://grafana.com/docs/grafana/latest/getting-started/getting-started/).

---

## Conclusion

As demonstrated in this article, it is easy to store and visualize the simulated data by configuring a flow using Node-RED’s graphical interface and deploying it on e-RT3 Plus. This opens up infinite opportunities to process, analyze, and visualize data with minimal time and effort.

---

## Appendix

It is possible to collect and visualize data by installing InfluxDB and Grafana on the e-RT3 Plus device. In some cases, users will find it more convenient to use this type of system configuration.

This section describes the procedure to install InfluxDB and Grafana on the e-RT3 Plus device.

### Install InfluxDB on e-RT3 Plus

Follow these steps to install and start InfluxDB:

1. Open an SSH terminal to communicate with the e-RT3 Plus device.

    >**Note**: To learn how to open an SSH terminal and communicate with e-RT3 Plus, refer to [Remote Communication with e-RT3 Plus](https://github.com/Yokogawa-Technologies-Solutions-India/e-RT3-docs/blob/master/Articles/e-RT3/Communication-with-e-RT3-Plus.md#communicating--with-e-rt3-plus-by-ssh).
2. Run the following commands to add the InfluxData repository.

    ```bash
    curl -s https://repos.influxdata.com/influxdb.key | sudo apt-key add -
    source /etc/lsb-release
    echo "deb https://repos.influxdata.com/${DISTRIB_ID,,} ${DISTRIB_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/influxdb.list
    ```

3. Run the following commands to install and start InfluxDB service.

    ```bash
    sudo apt update && sudo apt install influxdb
    sudo service influxdb start
    ```

    >  **Note**: For more information about enabling sudo privileges, refer to [Send telemetry data from e-RT3 Plus to Azure IoT hub](https://github.com/Yokogawa-Technologies-Solutions-India/e-RT3-docs/blob/master/Articles/Azure/Send-telemetry-data-from-e-RT3-to-azure-IoT-hub.md#enabling-sudo-user).

For more information about installing InfluxDB, refer to the [product documentation](https://docs.influxdata.com/influxdb/v1.8/introduction/install/).

>**Note**: If you are using a proxy, refer to the proxy settings described in [Proxy settings](https://github.com/Yokogawa-Technologies-Solutions-India/e-RT3-docs/blob/master/Articles/Azure/Send-telemetry-data-from-e-RT3-to-azure-IoT-hub.md#proxy-settings).

### Install Grafana on e-RT3 Plus

Follow these steps to install and configure Grafana:

1. Open an SSH terminal.
2. To install Grafana, perform the following steps:

    1. Run the following commands to install the required packages.

        ```bash
        sudo apt install -y apt-transport-https
        sudo apt install -y software-properties-common wget
        wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
        ```

    2. Run the following command to add the repository for stable releases.

        ```bash
        echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
        ```

    3. Run the following commands to install Grafana.

        ```bash
        sudo apt update
        sudo apt install grafana
        ```

3. Finally, run the following commands to start the service and verify that the service has started.

    ```bash
    sudo service grafana-server start
    sudo service grafana-server status
    ```

For more information about installing Grafana, refer to the [product documentation](https://grafana.com/docs/grafana/latest/installation/debian/).

### Proxy settings for Docker

Follow these steps to set the proxy settings for Docker in Windows:

1. Open a Command Prompt terminal to the server.
2. Navigate to the following path:

    `C:\Users\username\.docker`
3. Edit the `config.json` file by following the steps in [Configure the Docker Client](https://docs.docker.com/network/proxy/#configure-the-docker-client).

   If the `config.json` file does not exist, you must create it.

   If the `config.json` file exists, ensure that its contents follow this format:

    ```bash
    {
        "HttpHeaders":
        {
            "User-Agent":"Docker-Client/19.03.13 (windows)"
        },
        "auths":
        {
            "<registry name 1>.azurecr.io":{},
            "https://index.docker.io/v1/":{},
            "<registry name 2>.azurecr.io":{}
        },
        "credStore":"desktop",
        "credsStore":"desktop",
        "proxies":
        {
            "default":     
            {
                "httpProxy":"http://username:password@example.com:port/",
                "httpsProxy":"http://username:password@example.com:port/"
            }
        },
        "stackOrchestrator":"swarm"
    }
    ```

    This is an example of `httpProxy` and `httpsProxy` settings. Edit the details based on your environment as necessary.

4. Now, you must configure the Docker Desktop settings with the Proxy details.

   To configure the Docker Desktop settings, perform these steps:

   1. From the **Start** menu, open Docker Desktop.

        The Docker Desktop window appears.

        ![dockerwelcome](assets/node-red-1/dockerwelcomepage.jpg)

   2. In the upper-left corner, click the **Settings** icon.

        The *Settings* page appears.

        ![dockerwelcome](assets/Proxy_Settings_Docker.jpg)

   3. Click on the **Resources** tab, and then click **PROXIES**.

   4. Enable the **Manual proxy configuration** toggle key.

   5. In the **Web Server (HTTP)**  box, specify the following proxy URL:

        `http://{username}:{password}@{proxy-server-url}:{port}`

   6. In the **Secure Web Server (HTTPS)**  box, specify the following secure proxy URL:

        `http://{username}:{password}@{proxy-server-url}:{port}`

   7. Click **Apply & Restart** to apply the settings and restart Docker Desktop.

The proxy settings are configured.

### Proxy settings for npm

If you are using a proxy, run the following commands to configure the proxy settings for npm:

```bash
sudo npm -g config set proxy http://{username}:{password}@{proxy-server-url}:{port}
sudo npm -g config set https-proxy https://{username}:{password}@{proxy-server-url}:{port}
```

Here, `username` and `password` are the credentials of the server PC, `proxy-server-url` is the IP address of the server PC, and `port` is the port number of the server PC.

The proxy settings are configured.

---

## References

1. [Install InfluxDB 1.8 OSS](https://docs.influxdata.com/influxdb/v1.8/introduction/install/)
2. [Install Grafana on Ubuntu](https://grafana.com/docs/grafana/latest/installation/debian/)
3. [Install InfluxDB nodes](https://flows.nodered.org/node/node-red-contrib-influxdb)
4. [Getting started with InfluxDB](https://docs.influxdata.com/influxdb/v1.8/introduction/get-started/)
5. [Using InfluxDB in Grafana](https://grafana.com/docs/grafana/latest/datasources/influxdb/)
6. [Getting started with Grafana](https://grafana.com/docs/grafana/latest/getting-started/getting-started/)
7. [Install Node.js v10.x](https://github.com/nodesource/distributions/blob/master/README.md)
8. [Configure Docker to use a proxy server](https://docs.docker.com/network/proxy/)

---
---
