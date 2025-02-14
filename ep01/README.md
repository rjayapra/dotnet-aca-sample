# Azure Container Apps for .NET Developers

Hello 


Hello everybody! Containers! Cloud services that run containers! Microservice architectures! Cloud native! A bunch of words that confuse everyone!

Let's see if we can spend 2-3 minutes and clear up why containerizing your app is beneficial and the different Azure services and their use cases where you can run containerized apps. And we'll spend a bit more time on why Azure Container Apps hits a special sweet spot when it comes to hosting your applications.

Containers and container services are everywhere!
Containers are a fantastic way to produce repeatable environments across platforms and services. All of your application's code and dependencies get packaged up in a - well - container. And once you know it's running great in that container, you can be sure it'll run great in any service that supports containers.
And because these services allow you to create and then start and stop containers easily, they allow you to scale based on load and recover from failures, among other things. 
Now, you might have heard that containerized applications are the "one true way" to a cloud-native and microservice architecture. They definitely make that easier. But, they are also a great way to migrate existing monolith or not-so-microservice apps to the cloud.

But oh my goodness, there are so many options to host a containerized app!
That's true. There are several and upon first glance it can be confusing which service best fits your use case. So let's take a look at them.

Azure Functions
Let's start with Azure Functions. While you might not initially think of containers with Azure Functions, it’s worth noting there is a use case for it. Functions is a serverless, event-driven programming model. Something happens—like a blob is created in storage—and then some code runs. It also provides bindings to other Azure Services, making developing with them as simple as having parameters in your function definition. What is interesting is the Function runtime can be bundled into a container, allowing you to use serverless programming paradigms in a container and making it portable to other container-based platforms.

Azure App Service
Azure App Service provides fully managed hosting for web apps. You can deploy your websites or APIs via code or containers. App Service optimized for web applications. It's the workhorse of web app hosting in Azure. With App Service, you get scaling and load balancing, but you are limited to the frameworks and base container images that App Service currently supports. The classic platform as a service - you don't have to worry about the infrastructure, but you can't customize it to your exact needs either.

Azure Container Instances
Azure Container Instances offer containers on demand. And it's probably the least opinionated way to run containers in Azure. There’s no scaling, load balancing, or certificates—you need to manage all that. It provides a great way to start up an instance of your container and then you need to roll your own orchestration and management system on top, such as using Azure Kubernetes Service.

Azure Kubernetes Service (AKS)
AKS is a fully managed Kubernetes service. You get direct access to Kubernetes APIs, and all the configuration is within your control. However, you don’t have to worry about the physical infrastructure.

Azure Container Apps (ACA)
And finally, we have Azure Container Apps. ACA combines the best features of the above services in a fully managed environment and is opinionated, which means it provides best practices for most situations but still configurable. ACA allows you to build microservices and jobs, all based on containers. Don’t be misled by the term "microservices"—if you can refactor your monolith app to run in a container, ACA is a great first step for migration to the cloud.

You can run any container base image and have a lot of control over tweaking the underlying infrastructure. ACA runs on Kubernetes and supports OSS tech like Dapr, KEDA, and Envoy, enabling service discovery, traffic splitting, and more. You can scale based on traffic, CPU, or memory load. What’s cool is that ACA supports an event-driven architecture—also known as serverless—so it allows your app to scale to zero or easily scale up based on traffic.

In conclusion,
Moving your .NET apps to containers encapsulates your app’s logic and dependencies into a single package, making it easier to run across services, scale up, ensure consistency across environments, and is a solid first step in modernizing apps for cloud migration. 

Azure offers many places to deploy your containerized apps—from App Service to Kubernetes. However, Azure Container Apps hits the sweet spot by allowing considerable customization and control of the infrastructure while also providing best practices in a fully managed service.

Check out some samples and tutorials on using ACA at this link.
And there are more videos too - like how to add authentication to your app within ACA or refactoring a monolith into a microservice architecture. Hit that subscribe button and you'll be kept up to date on your ACA learning adventure.