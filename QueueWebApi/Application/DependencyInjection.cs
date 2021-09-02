﻿using QueueWebApi.Application;
using QueueWebApi.Domain.Models;
using System;
using System.Threading.Channels;

namespace Microsoft.Extensions.DependencyInjection
{
    public static partial class DependencyInjection
    {
        public static IServiceCollection AddApplication(this IServiceCollection services)
        {
            if (services == null)
            {
                throw new ArgumentNullException(nameof(services));
            }

            services.AddSingleton(Channel.CreateUnbounded<Work>());
            services.AddScoped<IWorkService, WorkService>();
            services.AddHostedService<WorkerBackgroundService>();

            return services;
        }
    }
}
