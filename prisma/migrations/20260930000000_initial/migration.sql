-- Initial PostgreSQL schema for Fleet OS.

CREATE TYPE "UserStatus" AS ENUM ('ACTIVE', 'INACTIVE', 'SUSPENDED');
CREATE TYPE "BookingStatus" AS ENUM ('PENDING', 'AWAITING_PAYMENT', 'PAID', 'CONFIRMED', 'DRIVER_ASSIGNED', 'VEHICLE_ASSIGNED', 'DRIVER_EN_ROUTE', 'DRIVER_ARRIVED', 'PASSENGER_ONBOARD', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED', 'REFUNDED');
CREATE TYPE "PaymentStatus" AS ENUM ('PENDING', 'AUTHORIZED', 'PAID', 'FAILED', 'REFUNDED', 'PARTIALLY_REFUNDED');
CREATE TYPE "PublishStatus" AS ENUM ('DRAFT', 'PUBLISHED', 'ARCHIVED');
CREATE TYPE "LocationType" AS ENUM ('CITY', 'AIRPORT', 'DESTINATION', 'ATTRACTION', 'PICKUP_ZONE', 'SERVICE_ZONE');
CREATE TYPE "DiscountType" AS ENUM ('PERCENTAGE', 'FIXED');
CREATE TYPE "TicketStatus" AS ENUM ('OPEN', 'IN_PROGRESS', 'WAITING_CUSTOMER', 'RESOLVED', 'CLOSED');

CREATE TABLE "User" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "email" TEXT NOT NULL UNIQUE,
  "passwordHash" TEXT,
  "name" TEXT NOT NULL,
  "status" "UserStatus" NOT NULL DEFAULT 'ACTIVE',
  "lastLoginAt" TIMESTAMP(3),
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,
  "deletedAt" TIMESTAMP(3)
);

CREATE TABLE "Role" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "name" TEXT NOT NULL UNIQUE,
  "description" TEXT,
  "isSystem" BOOLEAN NOT NULL DEFAULT FALSE,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL
);

CREATE TABLE "Permission" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "key" TEXT NOT NULL UNIQUE,
  "description" TEXT
);

CREATE TABLE "UserRole" (
  "userId" TEXT NOT NULL,
  "roleId" TEXT NOT NULL,
  PRIMARY KEY ("userId", "roleId")
);

CREATE TABLE "RolePermission" (
  "roleId" TEXT NOT NULL,
  "permissionId" TEXT NOT NULL,
  PRIMARY KEY ("roleId", "permissionId")
);

CREATE TABLE "CustomerProfile" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "userId" TEXT NOT NULL UNIQUE,
  "phone" TEXT,
  "country" TEXT,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL
);

CREATE TABLE "CustomerAddress" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "customerId" TEXT NOT NULL,
  "label" TEXT NOT NULL,
  "address" TEXT NOT NULL,
  "latitude" DECIMAL(10,7),
  "longitude" DECIMAL(10,7)
);

CREATE TABLE "SavedPlace" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "customerId" TEXT NOT NULL,
  "name" TEXT NOT NULL,
  "address" TEXT NOT NULL,
  "latitude" DECIMAL(10,7),
  "longitude" DECIMAL(10,7)
);

CREATE TABLE "ServiceCategory" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "name" TEXT NOT NULL,
  "slug" TEXT NOT NULL UNIQUE,
  "displayOrder" INTEGER NOT NULL DEFAULT 0,
  "isActive" BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE "Service" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "categoryId" TEXT,
  "title" TEXT NOT NULL,
  "slug" TEXT NOT NULL UNIQUE,
  "icon" TEXT,
  "imageUrl" TEXT,
  "description" TEXT,
  "isActive" BOOLEAN NOT NULL DEFAULT TRUE,
  "showOnHomepage" BOOLEAN NOT NULL DEFAULT TRUE,
  "displayOrder" INTEGER NOT NULL DEFAULT 0,
  "bookingFields" JSONB,
  "pricingConfig" JSONB,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,
  "deletedAt" TIMESTAMP(3)
);

CREATE TABLE "ServiceSetting" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "serviceId" TEXT NOT NULL,
  "key" TEXT NOT NULL,
  "value" JSONB NOT NULL,
  UNIQUE ("serviceId", "key")
);

CREATE TABLE "VehicleCategory" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "name" TEXT NOT NULL,
  "slug" TEXT NOT NULL UNIQUE,
  "description" TEXT,
  "displayOrder" INTEGER NOT NULL DEFAULT 0,
  "isActive" BOOLEAN NOT NULL DEFAULT TRUE,
  "deletedAt" TIMESTAMP(3)
);

CREATE TABLE "VehicleClass" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "name" TEXT NOT NULL,
  "slug" TEXT NOT NULL UNIQUE,
  "multiplier" DECIMAL(8,2) NOT NULL DEFAULT 1
);

CREATE TABLE "Vehicle" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "categoryId" TEXT NOT NULL,
  "classId" TEXT,
  "name" TEXT NOT NULL,
  "slug" TEXT NOT NULL UNIQUE,
  "fleetNumber" TEXT NOT NULL UNIQUE,
  "make" TEXT,
  "model" TEXT,
  "year" INTEGER,
  "passengerCapacity" INTEGER NOT NULL,
  "luggageCapacity" INTEGER NOT NULL,
  "doors" INTEGER,
  "transmission" TEXT,
  "fuelType" TEXT,
  "baseFare" DECIMAL(12,2) NOT NULL,
  "perKmRate" DECIMAL(12,2) NOT NULL,
  "hourlyRate" DECIMAL(12,2) NOT NULL,
  "dailyRate" DECIMAL(12,2) NOT NULL,
  "airportEligible" BOOLEAN NOT NULL DEFAULT TRUE,
  "rentalEligible" BOOLEAN NOT NULL DEFAULT FALSE,
  "chauffeurEligible" BOOLEAN NOT NULL DEFAULT TRUE,
  "groupEligible" BOOLEAN NOT NULL DEFAULT FALSE,
  "isAvailable" BOOLEAN NOT NULL DEFAULT TRUE,
  "isFeatured" BOOLEAN NOT NULL DEFAULT FALSE,
  "isPublished" BOOLEAN NOT NULL DEFAULT TRUE,
  "displayOrder" INTEGER NOT NULL DEFAULT 0,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,
  "deletedAt" TIMESTAMP(3)
);

CREATE TABLE "VehicleFeature" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "vehicleId" TEXT NOT NULL,
  "name" TEXT NOT NULL,
  "icon" TEXT,
  UNIQUE ("vehicleId", "name")
);

CREATE TABLE "VehicleImage" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "vehicleId" TEXT NOT NULL,
  "mediaId" TEXT,
  "url" TEXT NOT NULL,
  "altText" TEXT,
  "displayOrder" INTEGER NOT NULL DEFAULT 0,
  "isPrimary" BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE "VehicleAvailability" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "vehicleId" TEXT NOT NULL,
  "startsAt" TIMESTAMP(3) NOT NULL,
  "endsAt" TIMESTAMP(3) NOT NULL,
  "isAvailable" BOOLEAN NOT NULL DEFAULT TRUE,
  "reason" TEXT
);

CREATE TABLE "VehicleMaintenance" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "vehicleId" TEXT NOT NULL,
  "startsAt" TIMESTAMP(3) NOT NULL,
  "endsAt" TIMESTAMP(3),
  "type" TEXT NOT NULL,
  "notes" TEXT,
  "cost" DECIMAL(12,2)
);

CREATE TABLE "Driver" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "name" TEXT NOT NULL,
  "phone" TEXT NOT NULL,
  "email" TEXT,
  "licenseNumber" TEXT NOT NULL UNIQUE,
  "isActive" BOOLEAN NOT NULL DEFAULT TRUE,
  "photoUrl" TEXT,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL
);

CREATE TABLE "DriverAvailability" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "driverId" TEXT NOT NULL,
  "startsAt" TIMESTAMP(3) NOT NULL,
  "endsAt" TIMESTAMP(3) NOT NULL,
  "isAvailable" BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE "City" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "name" TEXT NOT NULL,
  "slug" TEXT NOT NULL UNIQUE,
  "region" TEXT,
  "isActive" BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE "Location" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "cityId" TEXT,
  "name" TEXT NOT NULL,
  "slug" TEXT NOT NULL UNIQUE,
  "type" "LocationType" NOT NULL,
  "address" TEXT,
  "latitude" DECIMAL(10,7) NOT NULL,
  "longitude" DECIMAL(10,7) NOT NULL,
  "imageUrl" TEXT,
  "isActive" BOOLEAN NOT NULL DEFAULT TRUE,
  "isFeatured" BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE "Airport" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "cityId" TEXT NOT NULL,
  "code" TEXT NOT NULL UNIQUE,
  "name" TEXT NOT NULL,
  "terminalInfo" TEXT
);

CREATE TABLE "Destination" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "cityId" TEXT NOT NULL,
  "name" TEXT NOT NULL,
  "slug" TEXT NOT NULL UNIQUE,
  "description" TEXT,
  "imageUrl" TEXT,
  "isActive" BOOLEAN NOT NULL DEFAULT TRUE,
  "isFeatured" BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE "Attraction" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "cityId" TEXT NOT NULL,
  "name" TEXT NOT NULL,
  "slug" TEXT NOT NULL UNIQUE,
  "description" TEXT,
  "imageUrl" TEXT,
  "isActive" BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE "Route" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "serviceId" TEXT NOT NULL,
  "originId" TEXT NOT NULL,
  "destinationId" TEXT NOT NULL,
  "slug" TEXT NOT NULL UNIQUE,
  "durationMinutes" INTEGER NOT NULL,
  "distanceKm" DECIMAL(10,2) NOT NULL,
  "startingPrice" DECIMAL(12,2) NOT NULL,
  "imageUrl" TEXT,
  "isFeatured" BOOLEAN NOT NULL DEFAULT FALSE,
  "isActive" BOOLEAN NOT NULL DEFAULT TRUE,
  "displayOrder" INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE "RouteStop" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "routeId" TEXT NOT NULL,
  "locationId" TEXT NOT NULL,
  "name" TEXT NOT NULL,
  "displayOrder" INTEGER NOT NULL
);

CREATE TABLE "RoutePricing" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "routeId" TEXT NOT NULL,
  "vehicleCategoryId" TEXT,
  "basePrice" DECIMAL(12,2) NOT NULL
);

CREATE TABLE "PricingZone" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "name" TEXT NOT NULL,
  "geoJson" JSONB NOT NULL,
  "isActive" BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE "PricingRule" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "name" TEXT NOT NULL,
  "serviceId" TEXT,
  "vehicleId" TEXT,
  "vehicleCategoryId" TEXT,
  "zoneId" TEXT,
  "baseFare" DECIMAL(12,2),
  "perKm" DECIMAL(12,2),
  "perMinute" DECIMAL(12,2),
  "hourly" DECIMAL(12,2),
  "daily" DECIMAL(12,2),
  "multiplier" DECIMAL(8,2),
  "startsAt" TIMESTAMP(3),
  "endsAt" TIMESTAMP(3),
  "priority" INTEGER NOT NULL DEFAULT 0,
  "isActive" BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE "Surcharge" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "pricingRuleId" TEXT,
  "name" TEXT NOT NULL,
  "type" TEXT NOT NULL,
  "amount" DECIMAL(12,2) NOT NULL,
  "conditions" JSONB,
  "isActive" BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE "Extra" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "name" TEXT NOT NULL,
  "slug" TEXT NOT NULL UNIQUE,
  "description" TEXT,
  "price" DECIMAL(12,2) NOT NULL,
  "isActive" BOOLEAN NOT NULL DEFAULT TRUE,
  "displayOrder" INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE "Promotion" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "title" TEXT NOT NULL,
  "description" TEXT,
  "discountType" "DiscountType" NOT NULL,
  "discountValue" DECIMAL(12,2) NOT NULL,
  "minimumBooking" DECIMAL(12,2),
  "maximumDiscount" DECIMAL(12,2),
  "startsAt" TIMESTAMP(3) NOT NULL,
  "endsAt" TIMESTAMP(3) NOT NULL,
  "usageLimit" INTEGER,
  "perUserLimit" INTEGER,
  "isActive" BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE "Coupon" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "promotionId" TEXT NOT NULL,
  "code" TEXT NOT NULL UNIQUE,
  "usageCount" INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE "PromotionService" (
  "promotionId" TEXT NOT NULL,
  "serviceId" TEXT NOT NULL,
  PRIMARY KEY ("promotionId", "serviceId")
);

CREATE TABLE "PromotionVehicle" (
  "promotionId" TEXT NOT NULL,
  "vehicleId" TEXT NOT NULL,
  PRIMARY KEY ("promotionId", "vehicleId")
);

CREATE TABLE "Booking" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "reference" TEXT NOT NULL UNIQUE,
  "userId" TEXT,
  "serviceId" TEXT NOT NULL,
  "routeId" TEXT,
  "pickupId" TEXT NOT NULL,
  "destinationId" TEXT,
  "driverId" TEXT,
  "scheduledAt" TIMESTAMP(3) NOT NULL,
  "passengerCount" INTEGER NOT NULL,
  "luggageCount" INTEGER NOT NULL,
  "status" "BookingStatus" NOT NULL DEFAULT 'PENDING',
  "flightNumber" TEXT,
  "customerNotes" TEXT,
  "internalNotes" TEXT,
  "priceSnapshot" JSONB NOT NULL,
  "subtotal" DECIMAL(12,2) NOT NULL,
  "discount" DECIMAL(12,2) NOT NULL DEFAULT 0,
  "tax" DECIMAL(12,2) NOT NULL DEFAULT 0,
  "fees" DECIMAL(12,2) NOT NULL DEFAULT 0,
  "total" DECIMAL(12,2) NOT NULL,
  "currency" TEXT NOT NULL DEFAULT 'TWD',
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,
  "cancelledAt" TIMESTAMP(3)
);

CREATE TABLE "BookingPassenger" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "bookingId" TEXT NOT NULL,
  "firstName" TEXT NOT NULL,
  "lastName" TEXT NOT NULL,
  "type" TEXT NOT NULL
);

CREATE TABLE "BookingVehicle" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "bookingId" TEXT NOT NULL,
  "vehicleId" TEXT NOT NULL,
  "price" DECIMAL(12,2) NOT NULL
);

CREATE TABLE "BookingExtra" (
  "bookingId" TEXT NOT NULL,
  "extraId" TEXT NOT NULL,
  "quantity" INTEGER NOT NULL DEFAULT 1,
  "unitPrice" DECIMAL(12,2) NOT NULL,
  PRIMARY KEY ("bookingId", "extraId")
);

CREATE TABLE "BookingStatusHistory" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "bookingId" TEXT NOT NULL,
  "fromStatus" "BookingStatus",
  "toStatus" "BookingStatus" NOT NULL,
  "notes" TEXT,
  "changedById" TEXT,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE "Order" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "orderNumber" TEXT NOT NULL UNIQUE,
  "bookingId" TEXT NOT NULL UNIQUE,
  "subtotal" DECIMAL(12,2) NOT NULL,
  "discount" DECIMAL(12,2) NOT NULL,
  "tax" DECIMAL(12,2) NOT NULL,
  "fees" DECIMAL(12,2) NOT NULL,
  "total" DECIMAL(12,2) NOT NULL,
  "currency" TEXT NOT NULL DEFAULT 'TWD',
  "paymentStatus" "PaymentStatus" NOT NULL DEFAULT 'PENDING',
  "orderStatus" TEXT NOT NULL,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL
);

CREATE TABLE "Payment" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "bookingId" TEXT NOT NULL,
  "amount" DECIMAL(12,2) NOT NULL,
  "currency" TEXT NOT NULL DEFAULT 'TWD',
  "provider" TEXT NOT NULL,
  "status" "PaymentStatus" NOT NULL DEFAULT 'PENDING',
  "providerReference" TEXT,
  "safeMetadata" JSONB,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL
);

CREATE TABLE "PaymentTransaction" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "paymentId" TEXT NOT NULL,
  "type" TEXT NOT NULL,
  "amount" DECIMAL(12,2) NOT NULL,
  "providerReference" TEXT,
  "metadata" JSONB,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE "Refund" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "paymentId" TEXT NOT NULL,
  "amount" DECIMAL(12,2) NOT NULL,
  "reason" TEXT NOT NULL,
  "status" TEXT NOT NULL,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE "Favorite" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "userId" TEXT NOT NULL,
  "entityType" TEXT NOT NULL,
  "entityId" TEXT NOT NULL,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE ("userId", "entityType", "entityId")
);

CREATE TABLE "Review" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "userId" TEXT NOT NULL,
  "bookingId" TEXT NOT NULL UNIQUE,
  "rating" INTEGER NOT NULL,
  "title" TEXT,
  "content" TEXT NOT NULL,
  "status" "PublishStatus" NOT NULL DEFAULT 'DRAFT',
  "isFeatured" BOOLEAN NOT NULL DEFAULT FALSE,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL
);

CREATE TABLE "HeroSlide" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "title" TEXT NOT NULL,
  "highlightedText" TEXT,
  "subtitle" TEXT,
  "desktopImage" TEXT NOT NULL,
  "mobileImage" TEXT,
  "ctaText" TEXT,
  "ctaUrl" TEXT,
  "overlay" TEXT,
  "textAlignment" TEXT NOT NULL DEFAULT 'left',
  "isActive" BOOLEAN NOT NULL DEFAULT TRUE,
  "displayOrder" INTEGER NOT NULL DEFAULT 0,
  "startsAt" TIMESTAMP(3),
  "endsAt" TIMESTAMP(3),
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL
);

CREATE TABLE "HomepageSection" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "key" TEXT NOT NULL UNIQUE,
  "title" TEXT NOT NULL,
  "subtitle" TEXT,
  "content" TEXT,
  "background" TEXT,
  "imageUrl" TEXT,
  "ctaText" TEXT,
  "ctaUrl" TEXT,
  "layout" TEXT,
  "isActive" BOOLEAN NOT NULL DEFAULT TRUE,
  "displayOrder" INTEGER NOT NULL DEFAULT 0,
  "publishAt" TIMESTAMP(3),
  "unpublishAt" TIMESTAMP(3),
  "updatedAt" TIMESTAMP(3) NOT NULL
);

CREATE TABLE "HomepageSectionItem" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "sectionId" TEXT NOT NULL,
  "title" TEXT NOT NULL,
  "subtitle" TEXT,
  "content" TEXT,
  "imageUrl" TEXT,
  "icon" TEXT,
  "ctaText" TEXT,
  "ctaUrl" TEXT,
  "metadata" JSONB,
  "isActive" BOOLEAN NOT NULL DEFAULT TRUE,
  "displayOrder" INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE "NavigationItem" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "label" TEXT NOT NULL,
  "url" TEXT NOT NULL,
  "icon" TEXT,
  "parentId" TEXT,
  "location" TEXT NOT NULL DEFAULT 'header',
  "isActive" BOOLEAN NOT NULL DEFAULT TRUE,
  "displayOrder" INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE "Banner" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "title" TEXT NOT NULL,
  "imageUrl" TEXT,
  "ctaUrl" TEXT,
  "placement" TEXT NOT NULL,
  "isActive" BOOLEAN NOT NULL DEFAULT TRUE,
  "startsAt" TIMESTAMP(3),
  "endsAt" TIMESTAMP(3)
);

CREATE TABLE "PromotionBanner" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "promotionId" TEXT,
  "title" TEXT NOT NULL,
  "imageUrl" TEXT,
  "isActive" BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE "MediaAsset" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "storageKey" TEXT NOT NULL UNIQUE,
  "url" TEXT NOT NULL,
  "mimeType" TEXT NOT NULL,
  "size" INTEGER NOT NULL,
  "width" INTEGER,
  "height" INTEGER,
  "title" TEXT,
  "altText" TEXT,
  "createdById" TEXT,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE "SiteSetting" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "key" TEXT NOT NULL UNIQUE,
  "value" JSONB NOT NULL,
  "isPublic" BOOLEAN NOT NULL DEFAULT FALSE,
  "updatedAt" TIMESTAMP(3) NOT NULL
);

CREATE TABLE "SEOSetting" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "path" TEXT NOT NULL UNIQUE,
  "title" TEXT NOT NULL,
  "description" TEXT,
  "imageUrl" TEXT,
  "noIndex" BOOLEAN NOT NULL DEFAULT FALSE,
  "updatedAt" TIMESTAMP(3) NOT NULL
);

CREATE TABLE "Notification" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "userId" TEXT,
  "channel" TEXT NOT NULL,
  "type" TEXT NOT NULL,
  "title" TEXT NOT NULL,
  "body" TEXT NOT NULL,
  "status" TEXT NOT NULL DEFAULT 'pending',
  "metadata" JSONB,
  "sentAt" TIMESTAMP(3),
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE "NotificationTemplate" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "key" TEXT NOT NULL UNIQUE,
  "channel" TEXT NOT NULL,
  "subject" TEXT,
  "body" TEXT NOT NULL,
  "isActive" BOOLEAN NOT NULL DEFAULT TRUE,
  "updatedAt" TIMESTAMP(3) NOT NULL
);

CREATE TABLE "AuditLog" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "actorId" TEXT,
  "action" TEXT NOT NULL,
  "entity" TEXT NOT NULL,
  "entityId" TEXT,
  "oldValue" JSONB,
  "newValue" JSONB,
  "ipAddress" TEXT,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE "SupportTicket" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "reference" TEXT NOT NULL UNIQUE,
  "userId" TEXT,
  "subject" TEXT NOT NULL,
  "description" TEXT NOT NULL,
  "status" "TicketStatus" NOT NULL DEFAULT 'OPEN',
  "priority" TEXT NOT NULL DEFAULT 'normal',
  "assignedToId" TEXT,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL
);

ALTER TABLE "UserRole" ADD CONSTRAINT "UserRole_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User" ("id") ON DELETE CASCADE;
ALTER TABLE "UserRole" ADD CONSTRAINT "UserRole_roleId_fkey" FOREIGN KEY ("roleId") REFERENCES "Role" ("id") ON DELETE CASCADE;
ALTER TABLE "RolePermission" ADD CONSTRAINT "RolePermission_roleId_fkey" FOREIGN KEY ("roleId") REFERENCES "Role" ("id") ON DELETE CASCADE;
ALTER TABLE "RolePermission" ADD CONSTRAINT "RolePermission_permissionId_fkey" FOREIGN KEY ("permissionId") REFERENCES "Permission" ("id") ON DELETE CASCADE;
ALTER TABLE "CustomerProfile" ADD CONSTRAINT "CustomerProfile_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User" ("id") ON DELETE CASCADE;
ALTER TABLE "CustomerAddress" ADD CONSTRAINT "CustomerAddress_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES "CustomerProfile" ("id") ON DELETE CASCADE;
ALTER TABLE "SavedPlace" ADD CONSTRAINT "SavedPlace_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES "CustomerProfile" ("id") ON DELETE CASCADE;
ALTER TABLE "Service" ADD CONSTRAINT "Service_categoryId_fkey" FOREIGN KEY ("categoryId") REFERENCES "ServiceCategory" ("id");
ALTER TABLE "ServiceSetting" ADD CONSTRAINT "ServiceSetting_serviceId_fkey" FOREIGN KEY ("serviceId") REFERENCES "Service" ("id") ON DELETE CASCADE;
ALTER TABLE "Vehicle" ADD CONSTRAINT "Vehicle_categoryId_fkey" FOREIGN KEY ("categoryId") REFERENCES "VehicleCategory" ("id");
ALTER TABLE "Vehicle" ADD CONSTRAINT "Vehicle_classId_fkey" FOREIGN KEY ("classId") REFERENCES "VehicleClass" ("id");
ALTER TABLE "VehicleFeature" ADD CONSTRAINT "VehicleFeature_vehicleId_fkey" FOREIGN KEY ("vehicleId") REFERENCES "Vehicle" ("id") ON DELETE CASCADE;
ALTER TABLE "VehicleImage" ADD CONSTRAINT "VehicleImage_vehicleId_fkey" FOREIGN KEY ("vehicleId") REFERENCES "Vehicle" ("id") ON DELETE CASCADE;
ALTER TABLE "VehicleImage" ADD CONSTRAINT "VehicleImage_mediaId_fkey" FOREIGN KEY ("mediaId") REFERENCES "MediaAsset" ("id");
ALTER TABLE "VehicleAvailability" ADD CONSTRAINT "VehicleAvailability_vehicleId_fkey" FOREIGN KEY ("vehicleId") REFERENCES "Vehicle" ("id") ON DELETE CASCADE;
ALTER TABLE "VehicleMaintenance" ADD CONSTRAINT "VehicleMaintenance_vehicleId_fkey" FOREIGN KEY ("vehicleId") REFERENCES "Vehicle" ("id") ON DELETE CASCADE;
ALTER TABLE "DriverAvailability" ADD CONSTRAINT "DriverAvailability_driverId_fkey" FOREIGN KEY ("driverId") REFERENCES "Driver" ("id") ON DELETE CASCADE;
ALTER TABLE "Location" ADD CONSTRAINT "Location_cityId_fkey" FOREIGN KEY ("cityId") REFERENCES "City" ("id");
ALTER TABLE "Airport" ADD CONSTRAINT "Airport_cityId_fkey" FOREIGN KEY ("cityId") REFERENCES "City" ("id");
ALTER TABLE "Destination" ADD CONSTRAINT "Destination_cityId_fkey" FOREIGN KEY ("cityId") REFERENCES "City" ("id");
ALTER TABLE "Attraction" ADD CONSTRAINT "Attraction_cityId_fkey" FOREIGN KEY ("cityId") REFERENCES "City" ("id");
ALTER TABLE "Route" ADD CONSTRAINT "Route_serviceId_fkey" FOREIGN KEY ("serviceId") REFERENCES "Service" ("id");
ALTER TABLE "Route" ADD CONSTRAINT "Route_originId_fkey" FOREIGN KEY ("originId") REFERENCES "Location" ("id");
ALTER TABLE "Route" ADD CONSTRAINT "Route_destinationId_fkey" FOREIGN KEY ("destinationId") REFERENCES "Location" ("id");
ALTER TABLE "RouteStop" ADD CONSTRAINT "RouteStop_routeId_fkey" FOREIGN KEY ("routeId") REFERENCES "Route" ("id") ON DELETE CASCADE;
ALTER TABLE "RouteStop" ADD CONSTRAINT "RouteStop_locationId_fkey" FOREIGN KEY ("locationId") REFERENCES "Location" ("id");
ALTER TABLE "RoutePricing" ADD CONSTRAINT "RoutePricing_routeId_fkey" FOREIGN KEY ("routeId") REFERENCES "Route" ("id") ON DELETE CASCADE;
ALTER TABLE "PricingRule" ADD CONSTRAINT "PricingRule_serviceId_fkey" FOREIGN KEY ("serviceId") REFERENCES "Service" ("id");
ALTER TABLE "PricingRule" ADD CONSTRAINT "PricingRule_vehicleId_fkey" FOREIGN KEY ("vehicleId") REFERENCES "Vehicle" ("id");
ALTER TABLE "PricingRule" ADD CONSTRAINT "PricingRule_vehicleCategoryId_fkey" FOREIGN KEY ("vehicleCategoryId") REFERENCES "VehicleCategory" ("id");
ALTER TABLE "PricingRule" ADD CONSTRAINT "PricingRule_zoneId_fkey" FOREIGN KEY ("zoneId") REFERENCES "PricingZone" ("id");
ALTER TABLE "Surcharge" ADD CONSTRAINT "Surcharge_pricingRuleId_fkey" FOREIGN KEY ("pricingRuleId") REFERENCES "PricingRule" ("id");
ALTER TABLE "Coupon" ADD CONSTRAINT "Coupon_promotionId_fkey" FOREIGN KEY ("promotionId") REFERENCES "Promotion" ("id") ON DELETE CASCADE;
ALTER TABLE "PromotionService" ADD CONSTRAINT "PromotionService_promotionId_fkey" FOREIGN KEY ("promotionId") REFERENCES "Promotion" ("id") ON DELETE CASCADE;
ALTER TABLE "PromotionService" ADD CONSTRAINT "PromotionService_serviceId_fkey" FOREIGN KEY ("serviceId") REFERENCES "Service" ("id") ON DELETE CASCADE;
ALTER TABLE "PromotionVehicle" ADD CONSTRAINT "PromotionVehicle_promotionId_fkey" FOREIGN KEY ("promotionId") REFERENCES "Promotion" ("id") ON DELETE CASCADE;
ALTER TABLE "PromotionVehicle" ADD CONSTRAINT "PromotionVehicle_vehicleId_fkey" FOREIGN KEY ("vehicleId") REFERENCES "Vehicle" ("id") ON DELETE CASCADE;
ALTER TABLE "Booking" ADD CONSTRAINT "Booking_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User" ("id");
ALTER TABLE "Booking" ADD CONSTRAINT "Booking_serviceId_fkey" FOREIGN KEY ("serviceId") REFERENCES "Service" ("id");
ALTER TABLE "Booking" ADD CONSTRAINT "Booking_routeId_fkey" FOREIGN KEY ("routeId") REFERENCES "Route" ("id");
ALTER TABLE "Booking" ADD CONSTRAINT "Booking_pickupId_fkey" FOREIGN KEY ("pickupId") REFERENCES "Location" ("id");
ALTER TABLE "Booking" ADD CONSTRAINT "Booking_destinationId_fkey" FOREIGN KEY ("destinationId") REFERENCES "Location" ("id");
ALTER TABLE "Booking" ADD CONSTRAINT "Booking_driverId_fkey" FOREIGN KEY ("driverId") REFERENCES "Driver" ("id");
ALTER TABLE "BookingPassenger" ADD CONSTRAINT "BookingPassenger_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES "Booking" ("id") ON DELETE CASCADE;
ALTER TABLE "BookingVehicle" ADD CONSTRAINT "BookingVehicle_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES "Booking" ("id") ON DELETE CASCADE;
ALTER TABLE "BookingVehicle" ADD CONSTRAINT "BookingVehicle_vehicleId_fkey" FOREIGN KEY ("vehicleId") REFERENCES "Vehicle" ("id");
ALTER TABLE "BookingExtra" ADD CONSTRAINT "BookingExtra_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES "Booking" ("id") ON DELETE CASCADE;
ALTER TABLE "BookingExtra" ADD CONSTRAINT "BookingExtra_extraId_fkey" FOREIGN KEY ("extraId") REFERENCES "Extra" ("id");
ALTER TABLE "BookingStatusHistory" ADD CONSTRAINT "BookingStatusHistory_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES "Booking" ("id") ON DELETE CASCADE;
ALTER TABLE "Order" ADD CONSTRAINT "Order_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES "Booking" ("id");
ALTER TABLE "Payment" ADD CONSTRAINT "Payment_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES "Booking" ("id");
ALTER TABLE "PaymentTransaction" ADD CONSTRAINT "PaymentTransaction_paymentId_fkey" FOREIGN KEY ("paymentId") REFERENCES "Payment" ("id") ON DELETE CASCADE;
ALTER TABLE "Refund" ADD CONSTRAINT "Refund_paymentId_fkey" FOREIGN KEY ("paymentId") REFERENCES "Payment" ("id");
ALTER TABLE "Favorite" ADD CONSTRAINT "Favorite_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User" ("id") ON DELETE CASCADE;
ALTER TABLE "Review" ADD CONSTRAINT "Review_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User" ("id");
ALTER TABLE "Review" ADD CONSTRAINT "Review_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES "Booking" ("id");
ALTER TABLE "HomepageSectionItem" ADD CONSTRAINT "HomepageSectionItem_sectionId_fkey" FOREIGN KEY ("sectionId") REFERENCES "HomepageSection" ("id") ON DELETE CASCADE;
ALTER TABLE "AuditLog" ADD CONSTRAINT "AuditLog_actorId_fkey" FOREIGN KEY ("actorId") REFERENCES "User" ("id");
ALTER TABLE "SupportTicket" ADD CONSTRAINT "SupportTicket_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User" ("id");

CREATE INDEX "Service_isActive_showOnHomepage_displayOrder_idx" ON "Service" ("isActive", "showOnHomepage", "displayOrder");
CREATE INDEX "Vehicle_isPublished_isAvailable_isFeatured_displayOrder_idx" ON "Vehicle" ("isPublished", "isAvailable", "isFeatured", "displayOrder");
CREATE INDEX "VehicleAvailability_vehicleId_startsAt_endsAt_idx" ON "VehicleAvailability" ("vehicleId", "startsAt", "endsAt");
CREATE INDEX "Location_type_isActive_isFeatured_idx" ON "Location" ("type", "isActive", "isFeatured");
CREATE INDEX "Route_isActive_isFeatured_displayOrder_idx" ON "Route" ("isActive", "isFeatured", "displayOrder");
CREATE INDEX "RoutePricing_routeId_vehicleCategoryId_idx" ON "RoutePricing" ("routeId", "vehicleCategoryId");
CREATE INDEX "PricingRule_isActive_priority_idx" ON "PricingRule" ("isActive", "priority");
CREATE INDEX "Booking_status_scheduledAt_idx" ON "Booking" ("status", "scheduledAt");
CREATE INDEX "Booking_userId_createdAt_idx" ON "Booking" ("userId", "createdAt");
CREATE INDEX "BookingStatusHistory_bookingId_createdAt_idx" ON "BookingStatusHistory" ("bookingId", "createdAt");
CREATE INDEX "AuditLog_entity_entityId_createdAt_idx" ON "AuditLog" ("entity", "entityId", "createdAt");
