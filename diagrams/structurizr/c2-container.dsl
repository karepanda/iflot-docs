workspace "iFlot 2026 - Container Diagram" "Container Diagram for iFlot 2026" {

    model {

        dispatcher = person "Dispatcher / Traffic Operator" "Plans trips, assigns vehicles and drivers, and monitors daily transport operations."
        billingOperator = person "Billing Operator" "Manages freight charges, cargo guides, settlements, and billing-related processes."
        tenantAdministrator = person "Tenant Administrator" "Manages tenant configuration, users, roles, and access policies."

        identityProvider = softwareSystem "Identity Provider" "Provides authentication and identity federation." {
            tags "External"
        }

        taxAuthority = softwareSystem "Electronic Invoicing / Tax Authority" "Supports electronic invoicing and tax validation processes." {
            tags "External"
        }

        erpSystem = softwareSystem "ERP / Accounting System" "Receives accounting, billing, and reconciliation-related information." {
            tags "External"
        }

        notificationService = softwareSystem "Notification Service" "Sends operational and business notifications." {
            tags "External"
        }

        mapsProvider = softwareSystem "Maps / Geolocation Provider" "Provides mapping, routing, and geolocation capabilities." {
            tags "External"
        }

        observabilityPlatform = softwareSystem "Observability Platform" "Collects logs, metrics, and distributed traces. Provides dashboards and alerting for operational support." {
            tags "External"
        }

        iflot = softwareSystem "iFlot 2026" "Multi-tenant platform for terrestrial fleet and logistics operations." {

            webApp = container "iFlot Web Application" "Single-page application for dispatchers, billing operators, and tenant administrators." "React, TypeScript, Nginx" {
                tags "Frontend"
            }

            coreApi = container "iFlot Core API" "Core backend for transport operations, billing, access control, and master data. Exposes REST APIs consumed by the SPA." "Java 21, Spring Boot, Spring Security" {
                tags "Backend"

                accessModule = component "Access Module" "User management, roles, permissions, authentication, and audit of privileged actions. RBAC with fine-grained permission authorities." "Spring Security, RBAC"
                operationsModule = component "Operations Module" "Trip lifecycle, cargo guide lifecycle, tariff resolution, payment method enforcement, expense registration, and master data." "Spring MVC, Domain Model"
                billingModule = component "Billing Module" "Pre-invoice generation from operationally closed guides, receipt cancellation with state reversion, and pre-cancellation as a controlled document." "Spring MVC, Domain Model"
                reportingModule = component "Reporting Module" "Operational and billing reports with filters by vehicle, driver, period, and route." "Spring MVC, Read Model"
                otlpProxy = component "OTLP Proxy" "Receives OpenTelemetry browser signals through the backend and forwards them to the observability platform." "Spring MVC"
            }

            database = container "Operational Database" "Tenant-aware relational database. All operational records are associated with a tenant at the data model level. Cross-tenant access is architecturally prevented." "PostgreSQL 16" {
                tags "Database"
            }

            # --- People → Web App ---
            dispatcher -> webApp "Uses to plan trips, assign vehicles and drivers, and monitor operations" "HTTPS"
            billingOperator -> webApp "Uses to manage cargo guides, settlements, and billing" "HTTPS"
            tenantAdministrator -> webApp "Uses to manage users, roles, and access policies" "HTTPS"

            # --- Web App → API ---
            webApp -> coreApi "Sends API requests to" "REST / HTTPS / JSON"
            webApp -> otlpProxy "Sends browser traces and metrics to" "OTLP HTTP / HTTPS"

            # --- Modules → Database ---
            accessModule -> database "Reads and writes users, roles, permissions, and audit records" "JDBC / HikariCP"
            operationsModule -> database "Reads and writes trips, guides, vehicles, drivers, routes, and expenses" "JDBC / HikariCP"
            billingModule -> database "Reads and writes pre-invoices, receipts, and pre-cancellations" "JDBC / HikariCP"
            reportingModule -> database "Queries operational and billing data for reports" "JDBC / HikariCP"

            # --- API → External Systems ---
            coreApi -> identityProvider "Authenticates users with" "HTTPS / OIDC"
            coreApi -> taxAuthority "Submits electronic invoices and validates tax data with" "HTTPS"
            coreApi -> erpSystem "Exports accounting and billing records to" "HTTPS / REST"
            coreApi -> notificationService "Sends operational and business notifications through" "HTTPS"
            coreApi -> mapsProvider "Resolves routes and geolocation data from" "HTTPS"
            coreApi -> observabilityPlatform "Sends backend traces, metrics, and logs to" "OTLP gRPC"
            otlpProxy -> observabilityPlatform "Forwards browser telemetry to" "OTLP gRPC"
        }
    }

    views {

        container iflot "Containers" "iFlot 2026 - Container Diagram (C2)" {
            include *
            autolayout lr
        }

        component coreApi "Components" "iFlot Core API - Internal module structure" {
            include *
            autolayout tb
        }

        styles {
            element "Person" {
                shape Person
                background #1168bd
                color #ffffff
            }
            element "Frontend" {
                shape WebBrowser
                background #438dd5
                color #ffffff
            }
            element "Backend" {
                shape Hexagon
                background #2e6da4
                color #ffffff
            }
            element "Database" {
                shape Cylinder
                background #438dd5
                color #ffffff
            }
            element "External" {
                background #999999
                color #ffffff
            }
        }

        theme default
    }
}
