// ------------------------------------------------------------
//  Copyright (c) Microsoft Corporation.  All rights reserved.
//  Licensed under the MIT License (MIT). See License.txt in the repo root for license information.
// ------------------------------------------------------------

namespace VotingWeb.Controllers
{
    using Microsoft.AspNetCore.Mvc;
    using System;
    using System.Linq;
    using System.Fabric;
    using System.Fabric.Query;
    using System.Threading.Tasks;
    using System.Fabric.Description;

    public class HomeController : Controller
    {
        private readonly FabricClient fabricClient;
        private readonly StatelessServiceContext serviceContext;

        public HomeController(StatelessServiceContext serviceContext, FabricClient fabricClient)
        {
            this.fabricClient = fabricClient;
            this.serviceContext = serviceContext;
        }

        public async Task<IActionResult> Index(string poll)
        {
            Uri serviceName = VotingWeb.GetVotingDataServiceName(this.serviceContext, poll);

            ServiceList serviceList =
                await this.fabricClient.QueryManager.GetServiceListAsync(
                    new Uri(this.serviceContext.CodePackageActivationContext.ApplicationName),
                    serviceName);

            if (!serviceList.Any())
            {
                await this.fabricClient.ServiceManager.CreateServiceAsync(
                    new StatefulServiceDescription()
                    {
                        ApplicationName = new Uri(this.serviceContext.CodePackageActivationContext.ApplicationName),
                        HasPersistedState = true,
                        MinReplicaSetSize = 3,
                        TargetReplicaSetSize = 3,
                        ServiceName = serviceName,
                        ServiceTypeName = "VotingDataType",
                        ServicePackageActivationMode = ServicePackageActivationMode.ExclusiveProcess,
                        PartitionSchemeDescription = new UniformInt64RangePartitionSchemeDescription(3, 0, 25)
                    });
            }

            this.ViewData["Poll"] = serviceName;

            return this.View();
        }

        public IActionResult Error()
        {
            return this.View();
        }
    }
}