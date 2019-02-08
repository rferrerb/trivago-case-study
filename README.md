# Trivago Case Study
This repository contains all the source code and configuration files that are been used on the Trivago case study

## Infraestructure

### Virtual Machines
I have used my main computer, a windows machine, with virtualbox and vagrant to spin up a kubernetes cluster and a mysql NDB cluster.

Here is the diagram:
![Virtual Machine Infraestructure](https://raw.githubusercontent.com/rferrerb/trivago-case-study/master/diagrams/VM_diagram.jpg)

### Kubernetes
The cluster is based on one master node, two workers and bastion machine. From the master machine I am going to perform all the actions needed to spin up the App.

### MySQL Cluster
I decided to use a cluster based on VMs and not docker to avoid storage problems and because of my actual resources is the best option.

# Prepare the environment
This is the final diagram of the overall deployment:

![Virtual Machine Infraestructure](https://raw.githubusercontent.com/rferrerb/trivago-case-study/master/diagrams/app-diagram.png)

### Deploy Kubernetes cluster
To spin up quick and easy a kubernetes cluster I base my work on this repository: [Oracle Kubernetes]
This solution allows me to build a kubernetes cluster from the ground using Vagrant and kubeadm.

### Deploy Mysql cluster
The same work done with kubernetes but using this other repository: [Mysql Cluster]. Again with Vagrant and virtualbox we have ready in minutes a functional NDB Cluster.

### Deploy Nginx Ingress Controller
To be able to use services offered by kubernetes I need a way to expose it. In terms of keep the infraestructure as simple as possible I am going to use the Nginx Ingress controller. Deployed following the official instructions: [NGINX Ingress Installation]

### Deploy Prometheus - Alerting and Grafana
I need to deploy that stack to obtain metrics, create alarms and dashboards to monitoring all the platform. I have used the solution provided by CoreOS: [kube-prometheus]

### Deploy docker registry
Another resource that I need is a Docker Registry, a software capable of provide my custom docker images to the platform.
To deploy that app I have used the kubectl command to perform the actions to Kubernetes.
```sh
$ kubectl apply -f apps/docker-registry/registry.yaml
```
### Deploy jenkins
Jenkins is the core piece of my CI/CD strategy. With Docker I build a custom image with the required plugins and software.
Find the required files on https://github.com/rferrerb/trivago-case-study/tree/master/apps/jenkins
After that I have pushed the image to my private docker registry and deployed to kubernetes with:
```sh
$ kubectl apply -f manifests/jenkins
```
### Initial application deploy
First of all I make the initial build of the web aplication and pushed to the private docker registry using the Dockerfile located at https://github.com/rferrerb/trivago-app
I perform the first deployment with:
```sh
$ kubectl apply -f manifests/trivago-app
```
That command creates all the componentes needed in kubernetes to run the demo application.

# CI/CD
### Jenkins
I implemented a Jenkins pipeline that triggers using SCM Pooling on the repo: https://github.com/rferrerb/trivago-app
That pipeline is quite simple:
- Pulls the code
- Build the Golang WebApp
- Generate new docker image
- Push that tagged image to Docker repository
- Connects to Kubernetes and perform a deploy using RollingUpdate


### Todos and next steps

 - Improve monitoring, metrics, alerting and reactors.
 - Build a stage infraestructure.
 - Write tests and testing stage on Jenkins.
 - Improve pipeline triggers, actually using SCM pooling.
 - Introduce a vault solution to keep secrets.



[//]: # (These are reference links used in the body of this note and get stripped out when the markdown processor does its job. There is no need to format nicely because it shouldn't be seen. Thanks SO - http://stackoverflow.com/questions/4823468/store-comments-in-markdown-syntax)



[Oracle Kubernetes]: https://github.com/oracle/vagrant-boxes/tree/master/Kubernetes
[Mysql Cluster]:https://github.com/engineerball/vagrant-mysql-cluster
[NGINX Ingress Installation]: https://kubernetes.github.io/ingress-nginx/deploy/#bare-metal
[kube-prometheus]:https://github.com/coreos/prometheus-operator/tree/master/contrib/kube-prometheus
