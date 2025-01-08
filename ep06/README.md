# EP06: Cost Optimization for ACA

This episode is about cost optimization for Azure Container Apps. But before we dive into the fine tuning, it's important to understand what scenarios are best suited for Azure Container Apps, and understand how to cost is calculated. Than we can look at the cost optimization strategies, and how to monitor our Apps and stay informed about the costs.

## A service for each scenarios

When looking at [Azure Container Apps documentation](https://learn.microsoft.com/azure/container-apps/) in the section `About Azure Container Apps` there a page [Compare Container options in Azure](https://learn.microsoft.com/azure/container-apps/compare-options)


Going through all the different services where containers can be used we can learn that:

- Container Apps is 
  - Optimized to run general purpose containers, especially for applications that span many microservices deployed in containers.
  - Powered by Kubernetes and open-source technologies like Dapr, KEDA, and envoy.
  - Supports Kubernetes-style apps and microservices with features like service discovery and traffic splitting.
  - Enables event-driven application architectures by supporting scale based on traffic and pulling from event sources like queues, including scale to zero.
  - Supports running on demand, scheduled, and event-driven jobs.

- Container Apps is not/ doest not 
  - Doest not provide direct access to the underlying Kubernetes APIs. If you require access, you should use Azure Kubernetes Service (AKS). 
  - Is not the less "opinionated" choice when you need only one isolated container that doesn't required scaling, load balancing, nor certificates. In those cases Azure Container Instances (ACI) could be preferable.
  - When more ephemeral code or containers are needed, Azure Functions could be a better choice.

## Understanding the cost

Looking at those two pages we can understand better how the cost is calculated. 
- [Billing in Azure Container Apps](https://learn.microsoft.com/en-us/azure/container-apps/billing)
- [Azure Container Apps Pricing](https://azure.microsoft.com/en-us/pricing/details/container-apps/)


### Consumption plan

By default, Azure Container Apps runs in the Consumption plan and there are of two types of charges:

- Resource consumption: The amount of resources allocated to your container app on a per-second basis, billed in vCPU-seconds and GiB-seconds.
- HTTP requests: The number of HTTP requests your container app receives.
  
The following resources are free during each calendar month, per subscription:

- The first 180,000 vCPU-seconds
- The first 360,000 GiB-seconds
- The first 2 million HTTP requests

The number os running replicas will also impact the cost. We will see how we can change this, but before we do it's important to mentione another plan.

### Dedicated plan

Billing for apps and jobs running in the Dedicated plan is based on workload profile instances, not by individual applications. 



## Change the MIN and MAX number of replicas

You can change the number of replicas and the scaling directly in the Azure portal, but doing so would be overrided each time you deploy using the AZD CLI or the CI/CD pipeline. A better way would be to modify the bicep file and redeploy the app.

Open the `infra/resources.bicep` file and look for the `scaleMinReplicas` and `scaleMaxReplicas` for each containers. 

```bicep
```

explain the impact of the change.

## Monitoring Cost