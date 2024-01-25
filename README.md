# Lamp Stack with Docker Compose

This repository provides a simple setup for a LAMP (Linux, Apache, MySQL, PHP) stack using Docker Compose. It includes configurations for PHP, Apache, MariaDB, and phpMyAdmin. The setup is designed to be easily customizable based on your development needs.

## Prerequisites

Before you begin, ensure you have the following installed on your machine:

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)

## Usage

1. Clone this repository:

    ```bash
    git clone https://github.com/andrirosandi/lamp.git
    ```

2. Navigate to the project directory:

    ```bash
    cd lamp
    ```

3. Run the setup script:

    ```bash
    bash setup.sh
    ```

    Follow the prompts to configure your LAMP stack. You can customize options such as PHP version, port, PHP extensions, Composer, Laravel, MariaDB, phpMyAdmin, and more.

4. Once the configuration is complete, you will see a summary of your choices. Confirm to continue.

5. The script will generate the Dockerfile and docker-compose.yml files and, if confirmed, will run `docker-compose up -d` to start the containers.

6. Access your web application at `http://localhost:{your_port}` and phpMyAdmin at `http://localhost:{your_phpmyadmin_port}`.

## Customization

- **Dockerfile:** Modify the `Dockerfile` to adjust PHP configurations, extensions, or other dependencies.

- **docker-compose.yml:** Make changes to the `docker-compose.yml` file to adjust container names, volumes, and network configurations.

## Important Notes

- If containers with the same name already exist, the script will append "1" to avoid conflicts.

- You can manually edit the Dockerfile and docker-compose.yml files before running `docker-compose up -d` if you prefer.

## Contributing

Feel free to open issues or pull requests for any improvements or additional features you'd like to see.

## License

This project is licensed under the [MIT License](LICENSE).
