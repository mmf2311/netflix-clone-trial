# netflix-clone-trial

# Netflix Clone

A Netflix clone application built with React for the frontend and Node.js with Express for the backend. It uses various AWS services for deployment and infrastructure management, Docker for containerization, and GitHub Actions for CI/CD.

## Table of Contents

- [Netflix Clone](#netflix-clone)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Architecture](#architecture)
  - [Project Structure](#project-structure)
  - [Setup and Installation](#setup-and-installation)
    - [Prerequisites](#prerequisites)
    - [Environment Variables](#environment-variables)
    - [Frontend Setup](#frontend-setup)
    - [Backend Setup](#backend-setup)
    - [Docker Setup](#docker-setup)
    - [Terraform Setup](#terraform-setup)
  - [Branching Strategy](#branching-strategy)
  - [CI/CD Pipeline](#cicd-pipeline)
  - [Destroying the Infrastructure](#destroying-the-infrastructure)
  - [License](#license)
  - [Acknowledgements](#acknowledgements)

## Overview

This project is a full-stack Netflix clone application designed to showcase the use of modern web technologies and cloud infrastructure. The application fetches movie data from the TMDB API and displays it in a Netflix-like interface.

## Architecture

The application is structured as follows:

- **Frontend**: Built with React, served from an S3 bucket.
- **Backend**: Built with Node.js and Express, running in AWS ECS.
- **Infrastructure**: Managed with Terraform, deployed in AWS.

## Project Structure

```plaintext
netflix-clone/
├── frontend/
│   ├── src/
│   │   ├── App.js
│   │   ├── App.css
│   │   └── ...
│   ├── public/
│   ├── Dockerfile
│   ├── package.json
│   ├── package-lock.json
│   └── ...
├── backend/
│   ├── src/
│   │   ├── index.js
│   │   ├── movies.js
│   │   └── ...
│   ├── Dockerfile
│   ├── package.json
│   ├── package-lock.json
│   └── ...
├── infrastructure/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── ...
│   ├── stage/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── ...
│   ├── prod/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── ...
│   └── ...
├── .github/
│   └── workflows/
│       ├── ci-cd.yml
│       ├── destroy.yml
│       └── ...
└── README.md
