workspace "iFlot 2026 - System Context" "System Context Diagram for iFlot 2026" {

    model {
        dispatcher = person "Dispatcher / Traffic Operator" "Plans trips, assigns vehicles and drivers, and monitors daily transport operations."
        billingOperator = person "Billing Operator" "Manages freight charges, cargo guides, settlements, and billing-related processes."
        tenantAdministrator = person "Tenant Administrator" "Manages tenant configuration, users, roles, and access policies."

        iflot = softwareSystem "iFlot 2026" "Multi-tenant platform for terrestrial fleet and logistics operations, including trip management, freight control, cargo guides, operational visibility, and billing."

        identityProvider = softwareSystem "Identity Provider" "Provides authentication and identity federation."
        taxAuthority = softwareSystem "Electronic Invoicing / Tax Authority" "Supports electronic invoicing and tax validation processes."
        erpSystem = softwareSystem "ERP / Accounting System" "Receives accounting, billing, and reconciliation-related information."
        notificationService = softwareSystem "Notification Service" "Sends operational and business notifications."
        mapsProvider = softwareSystem "Maps / Geolocation Provider" "Provides mapping, routing, and geolocation capabilities."
        observabilityPlatform = softwareSystem "Observability Platform" "Collects logs, metrics, and traces for monitoring and operational support."

        dispatcher -> iflot "Plans and monitors transport operations"
        billingOperator -> iflot "Manages freight, guides, and billing"
        tenantAdministrator -> iflot "Administers tenant settings, users, and access"

        iflot -> identityProvider "Authenticates users with"
        iflot -> taxAuthority "Uses for electronic invoicing and tax validation"
        iflot -> erpSystem "Exchanges accounting and billing information with"
        iflot -> notificationService "Sends notifications through"
        iflot -> mapsProvider "Uses mapping and geolocation capabilities from"
        iflot -> observabilityPlatform "Sends telemetry to"
    }

    views {
        systemContext iflot "SystemContext" {
            include *
            autolayout lr
        }

        theme default
    }
}