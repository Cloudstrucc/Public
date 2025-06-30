#!/usr/bin/env python3
"""
Enhanced Python AI Agent for E-commerce Platform with Node.js API
"""

import asyncio
import aiohttp
import json
import logging
import os
import time
import random
from dataclasses import dataclass, asdict
from typing import List, Optional, Dict, Any
from datetime import datetime, timedelta
import sys

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('logs/agent.log'),
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger(__name__)

@dataclass
class ProductData:
    """Enhanced product data structure for Node.js API"""
    sourceProductId: str
    sourceSite: str
    title: str
    description: str
    sourcePrice: float
    currency: str
    images: List[str]
    category: str
    availability: bool
    supplierInfo: dict
    specifications: Dict[str, Any]
    reviewsCount: int
    rating: float
    shippingInfo: Dict[str, Any]
    inventoryLevel: str

class NodeJSProductScraper:
    """Node.js API-compatible product scraper"""
    
    def __init__(self, api_base_url: str = "http://express-api:3001"):
        self.api_base_url = api_base_url
        self.session = None
        
    async def __aenter__(self):
        timeout = aiohttp.ClientTimeout(total=30)
        self.session = aiohttp.ClientSession(timeout=timeout)
        return self
        
    async def __aexit__(self, exc_type, exc_val, exc_tb):
        if self.session:
            await self.session.close()

    async def scrape_demo_products(self) -> List[ProductData]:
        """Demo scraping with realistic data for Node.js API testing - 12 diverse products"""
        logger.info("Starting Node.js API demo product scraping...")
        
        await asyncio.sleep(2)  # Simulate scraping delay
        
        mock_products = [
            ProductData(
                sourceProductId="NODE001",
                sourceSite="nodejs-demo",
                title="🎧 Premium Wireless Noise-Cancelling Headphones",
                description="Professional-grade wireless headphones with advanced noise cancellation technology. Perfect for music production, gaming, and daily use with 30-hour battery life.",
                sourcePrice=45.99,
                currency="USD",
                images=[
                    "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400",
                    "https://images.unsplash.com/photo-1484704849700-f032a568e944?w=400"
                ],
                category="Electronics",
                availability=True,
                supplierInfo={
                    "rating": 4.8, 
                    "location": "Seoul", 
                    "shipping_time": "5-10 days",
                    "min_order": 1,
                    "supplier_name": "AudioTech Pro"
                },
                specifications={
                    "Battery": "30 hours", 
                    "Connectivity": "Bluetooth 5.2", 
                    "Noise Cancellation": "Advanced ANC",
                    "Water Resistance": "IPX4",
                    "Weight": "290g",
                    "Driver": "40mm Dynamic"
                },
                reviewsCount=2850,
                rating=4.8,
                shippingInfo={"cost": 0, "method": "Free express shipping", "estimated_days": 7},
                inventoryLevel="In Stock"
            ),
            ProductData(
                sourceProductId="NODE002", 
                sourceSite="nodejs-demo",
                title="💡 Smart WiFi RGB LED Strip Kit 10M",
                description="Extended 10-meter smart LED strip with app control, voice assistant compatibility, and music sync. Create stunning ambient lighting for any room or occasion.",
                sourcePrice=28.50,
                currency="USD",
                images=[
                    "https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400",
                    "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400"
                ],
                category="Home & Garden",
                availability=True,
                supplierInfo={
                    "rating": 4.6, 
                    "location": "Shanghai", 
                    "shipping_time": "7-14 days",
                    "min_order": 1,
                    "supplier_name": "BrightHome Electronics"
                },
                specifications={
                    "Length": "10 meters", 
                    "Colors": "16 million RGB", 
                    "Control": "WiFi + Bluetooth",
                    "Power": "36W",
                    "Voltage": "12V",
                    "Compatibility": "Alexa, Google, App"
                },
                reviewsCount=1890,
                rating=4.6,
                shippingInfo={"cost": 0, "method": "Free shipping", "estimated_days": 10},
                inventoryLevel="In Stock"
            ),
            ProductData(
                sourceProductId="NODE003",
                sourceSite="nodejs-demo",
                title="📱 Magnetic Wireless Charger Stand Pro",
                description="Premium magnetic wireless charging stand compatible with MagSafe. Features adjustable viewing angles and fast 15W charging for optimal convenience.",
                sourcePrice=19.99,
                currency="USD",
                images=[
                    "https://images.unsplash.com/photo-1609592173003-7044a27c4de8?w=400",
                    "https://images.unsplash.com/photo-1556656793-08538906a9f8?w=400"
                ],
                category="Accessories",
                availability=True,
                supplierInfo={
                    "rating": 4.7, 
                    "location": "Taipei", 
                    "shipping_time": "6-12 days",
                    "min_order": 1,
                    "supplier_name": "ChargeTech Solutions"
                },
                specifications={
                    "Charging Speed": "15W Fast Wireless", 
                    "Compatibility": "MagSafe + Qi", 
                    "Adjustable": "Multi-angle",
                    "Material": "Premium Aluminum",
                    "Safety": "Over-temp Protection",
                    "LED": "Status Indicator"
                },
                reviewsCount=1250,
                rating=4.7,
                shippingInfo={"cost": 2.99, "method": "Standard shipping", "estimated_days": 9},
                inventoryLevel="In Stock"
            ),
            ProductData(
                sourceProductId="NODE004",
                sourceSite="nodejs-demo",
                title="🔋 Ultra-Fast Portable Power Bank 20000mAh",
                description="High-capacity portable charger with 65W USB-C PD fast charging. Can charge laptops, phones, and tablets simultaneously with digital display.",
                sourcePrice=35.75,
                currency="USD",
                images=[
                    "https://images.unsplash.com/photo-1609592173003-7044a27c4de8?w=400"
                ],
                category="Electronics",
                availability=True,
                supplierInfo={
                    "rating": 4.5, 
                    "location": "Shenzhen", 
                    "shipping_time": "8-15 days",
                    "min_order": 1,
                    "supplier_name": "PowerMax Industries"
                },
                specifications={
                    "Capacity": "20,000mAh", 
                    "Output": "65W USB-C PD", 
                    "Ports": "3x USB + 1x USB-C",
                    "Display": "Digital LED",
                    "Fast Charging": "PD 3.0 + QC 4.0",
                    "Safety": "Multi-Protection"
                },
                reviewsCount=1650,
                rating=4.5,
                shippingInfo={"cost": 4.99, "method": "Express shipping", "estimated_days": 8},
                inventoryLevel="Limited Stock"
            ),
            ProductData(
                sourceProductId="NODE005",
                sourceSite="nodejs-demo",
                title="🎮 Ergonomic Gaming Mouse with RGB",
                description="Professional gaming mouse with 12000 DPI sensor, customizable RGB lighting, and programmable buttons. Designed for competitive gaming and productivity.",
                sourcePrice=24.99,
                currency="USD",
                images=[
                    "https://images.unsplash.com/photo-1527814050087-3793815479db?w=400"
                ],
                category="Electronics",
                availability=True,
                supplierInfo={
                    "rating": 4.4, 
                    "location": "Hong Kong", 
                    "shipping_time": "5-12 days",
                    "min_order": 1,
                    "supplier_name": "GameGear Pro"
                },
                specifications={
                    "DPI": "12,000 adjustable", 
                    "Buttons": "7 programmable", 
                    "RGB": "16.8M colors",
                    "Polling Rate": "1000Hz",
                    "Weight": "85g",
                    "Cable": "Braided USB-C"
                },
                reviewsCount=980,
                rating=4.4,
                shippingInfo={"cost": 3.50, "method": "Standard shipping", "estimated_days": 8},
                inventoryLevel="In Stock"
            ),
            ProductData(
                sourceProductId="NODE006",
                sourceSite="nodejs-demo",
                title="🏠 Smart Home Security Camera 4K",
                description="Advanced 4K security camera with AI motion detection, night vision, and cloud storage. Perfect for monitoring your home with smartphone alerts.",
                sourcePrice=89.99,
                currency="USD",
                images=[
                    "https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400"
                ],
                category="Home & Garden",
                availability=True,
                supplierInfo={
                    "rating": 4.6, 
                    "location": "Beijing", 
                    "shipping_time": "10-18 days",
                    "min_order": 1,
                    "supplier_name": "SecureVision Tech"
                },
                specifications={
                    "Resolution": "4K Ultra HD", 
                    "Night Vision": "Full Color", 
                    "Storage": "Cloud + Local",
                    "AI Features": "Person/Vehicle Detection",
                    "Weather Resistant": "IP66",
                    "Power": "PoE or DC"
                },
                reviewsCount=2400,
                rating=4.6,
                shippingInfo={"cost": 0, "method": "Free shipping", "estimated_days": 14},
                inventoryLevel="In Stock"
            ),
            ProductData(
                sourceProductId="NODE007",
                sourceSite="nodejs-demo",
                title="☕ Electric Coffee Grinder Pro",
                description="Premium burr coffee grinder with 40 grind settings and timer. Perfect for espresso, drip, and French press coffee preparation.",
                sourcePrice=67.50,
                currency="USD",
                images=[
                    "https://images.unsplash.com/photo-1559056199-641a0ac8b55e?w=400"
                ],
                category="Kitchen",
                availability=True,
                supplierInfo={
                    "rating": 4.8, 
                    "location": "Milan", 
                    "shipping_time": "12-20 days",
                    "min_order": 1,
                    "supplier_name": "CoffeeMax Europe"
                },
                specifications={
                    "Grind Settings": "40 precise levels", 
                    "Burr Type": "Conical steel", 
                    "Timer": "Digital with memory",
                    "Capacity": "350g beans",
                    "Motor": "150W low-speed",
                    "Noise Level": "Ultra-quiet"
                },
                reviewsCount=890,
                rating=4.8,
                shippingInfo={"cost": 12.99, "method": "International express", "estimated_days": 16},
                inventoryLevel="In Stock"
            ),
            ProductData(
                sourceProductId="NODE008",
                sourceSite="nodejs-demo",
                title="🎒 Waterproof Travel Backpack 35L",
                description="Durable waterproof backpack with laptop compartment, USB charging port, and anti-theft design. Perfect for travel and daily commuting.",
                sourcePrice=42.00,
                currency="USD",
                images=[
                    "https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=400"
                ],
                category="Travel",
                availability=True,
                supplierInfo={
                    "rating": 4.3, 
                    "location": "Vietnam", 
                    "shipping_time": "14-25 days",
                    "min_order": 1,
                    "supplier_name": "AdventureGear Co"
                },
                specifications={
                    "Capacity": "35 liters", 
                    "Material": "Waterproof nylon", 
                    "Laptop Size": "Up to 17 inches",
                    "USB Port": "External charging",
                    "Security": "Hidden zippers",
                    "Weight": "1.2kg"
                },
                reviewsCount=1560,
                rating=4.3,
                shippingInfo={"cost": 8.99, "method": "Economy shipping", "estimated_days": 20},
                inventoryLevel="In Stock"
            ),
            ProductData(
                sourceProductId="NODE009",
                sourceSite="nodejs-demo",
                title="🌱 Indoor Herb Garden Kit",
                description="Complete hydroponic herb growing system with LED grow lights. Grow fresh basil, mint, and parsley year-round in your kitchen.",
                sourcePrice=56.25,
                currency="USD",
                images=[
                    "https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=400"
                ],
                category="Home & Garden",
                availability=True,
                supplierInfo={
                    "rating": 4.5, 
                    "location": "Netherlands", 
                    "shipping_time": "8-15 days",
                    "min_order": 1,
                    "supplier_name": "GreenGrow Systems"
                },
                specifications={
                    "Growing Pods": "12 herb slots", 
                    "LED Lights": "Full spectrum", 
                    "Water Tank": "4 liter capacity",
                    "Growth Height": "Adjustable 24cm",
                    "Power": "28W energy efficient",
                    "Included": "Seeds + nutrients"
                },
                reviewsCount=750,
                rating=4.5,
                shippingInfo={"cost": 15.99, "method": "Express international", "estimated_days": 12},
                inventoryLevel="In Stock"
            ),
            ProductData(
                sourceProductId="NODE010",
                sourceSite="nodejs-demo",
                title="🏋️ Adjustable Dumbbells Set 40kg",
                description="Space-saving adjustable dumbbell set with quick-change plates. Perfect for home gym workouts with weight range from 2.5kg to 20kg per dumbbell.",
                sourcePrice=129.99,
                currency="USD",
                images=[
                    "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400"
                ],
                category="Fitness",
                availability=True,
                supplierInfo={
                    "rating": 4.7, 
                    "location": "Germany", 
                    "shipping_time": "15-25 days",
                    "min_order": 1,
                    "supplier_name": "FitnessPro GmbH"
                },
                specifications={
                    "Weight Range": "2.5kg - 20kg each", 
                    "Material": "Cast iron + rubber", 
                    "Handle": "Ergonomic grip",
                    "Plates": "Quick-lock system",
                    "Storage": "Compact design",
                    "Warranty": "2 years"
                },
                reviewsCount=640,
                rating=4.7,
                shippingInfo={"cost": 25.99, "method": "Heavy item shipping", "estimated_days": 20},
                inventoryLevel="Limited Stock"
            ),
            ProductData(
                sourceProductId="NODE011",
                sourceSite="nodejs-demo",
                title="📚 E-Reader with Backlight",
                description="6-inch e-ink display e-reader with adjustable warm light, waterproof design, and 8-week battery life. Perfect for reading anywhere.",
                sourcePrice=78.90,
                currency="USD",
                images=[
                    "https://images.unsplash.com/photo-1481178733974-87d62cd0cf34?w=400"
                ],
                category="Electronics",
                availability=True,
                supplierInfo={
                    "rating": 4.4, 
                    "location": "Japan", 
                    "shipping_time": "10-18 days",
                    "min_order": 1,
                    "supplier_name": "DigitalRead Tech"
                },
                specifications={
                    "Screen": "6 inch E-ink", 
                    "Resolution": "300 PPI", 
                    "Backlight": "Adjustable warm",
                    "Storage": "8GB (thousands of books)",
                    "Battery": "8 weeks",
                    "Waterproof": "IPX8 rated"
                },
                reviewsCount=1120,
                rating=4.4,
                shippingInfo={"cost": 9.99, "method": "Air mail", "estimated_days": 14},
                inventoryLevel="In Stock"
            ),
            ProductData(
                sourceProductId="NODE012",
                sourceSite="nodejs-demo",
                title="🎨 Digital Drawing Tablet with Pen",
                description="Professional 10-inch drawing tablet with 8192 pressure levels and battery-free stylus. Perfect for digital art, design, and online teaching.",
                sourcePrice=95.00,
                currency="USD",
                images=[
                    "https://images.unsplash.com/photo-1541961017774-22349e4a1262?w=400"
                ],
                category="Electronics",
                availability=True,
                supplierInfo={
                    "rating": 4.6, 
                    "location": "South Korea", 
                    "shipping_time": "7-14 days",
                    "min_order": 1,
                    "supplier_name": "ArtTech Digital"
                },
                specifications={
                    "Active Area": "10 x 6.25 inches", 
                    "Pressure Levels": "8192", 
                    "Pen": "Battery-free stylus",
                    "Compatibility": "Windows, Mac, Linux",
                    "Express Keys": "8 customizable",
                    "Software": "Multiple art programs"
                },
                reviewsCount=2890,
                rating=4.6,
                shippingInfo={"cost": 12.99, "method": "Express shipping", "estimated_days": 10},
                inventoryLevel="In Stock"
            )
        ]
        
        logger.info(f"Successfully scraped {len(mock_products)} products for Node.js API")
        return mock_products

    async def send_to_api(self, products: List[ProductData]) -> bool:
        """Send scraped products to Node.js API"""
        if not self.session:
            logger.error("Session not initialized")
            return False
            
        try:
            products_json = [asdict(product) for product in products]
            
            # Send products to Node.js API
            async with self.session.post(
                f"{self.api_base_url}/api/products/bulk-import",
                json=products_json,
                headers={
                    'Content-Type': 'application/json',
                    'User-Agent': 'NodeJS-AI-Agent/1.0'
                },
                ssl=False
            ) as response:
                if response.status == 200:
                    result = await response.json()
                    logger.info(f"Successfully sent {len(products)} products to Node.js API: {result}")
                    return True
                else:
                    error_text = await response.text()
                    logger.error(f"Node.js API request failed: {response.status} - {error_text}")
                    return False
                    
        except Exception as e:
            logger.error(f"Failed to send data to Node.js API: {e}")
            return False

async def main():
    """Main execution loop for Node.js platform"""
    logger.info("🚀 Starting Node.js AI Agent System...")
    
    cycle_count = 0
    
    while True:
        try:
            cycle_count += 1
            logger.info(f"=== ⚡ Node.js Cycle {cycle_count} ===")
            
            # Use context manager for scraper
            async with NodeJSProductScraper() as scraper:
                # Scrape products for Node.js API
                logger.info("🤖 Scraping products for Node.js API...")
                all_products = await scraper.scrape_demo_products()
                
                # Send to Node.js API
                logger.info("📤 Sending data to Node.js API...")
                api_success = await scraper.send_to_api(all_products)
                
                # Summary
                logger.info(f"""
=== ⚡ Node.js Cycle {cycle_count} Summary ===
Products processed: {len(all_products)}
Node.js API sync: {'✅ Success' if api_success else '❌ Failed'}
Database: PostgreSQL via Prisma
Frontend: Next.js with React SSR
Next cycle in 15 minutes...
==========================================
""")
            
            # Wait before next cycle (15 minutes)
            logger.info("⏳ Waiting 15 minutes before next cycle...")
            await asyncio.sleep(900)
            
        except KeyboardInterrupt:
            logger.info("🛑 Node.js Agent stopped by user")
            break
        except Exception as e:
            logger.error(f"💥 Error in Node.js main loop: {e}")
            logger.info("🔄 Retrying in 1 minute...")
            await asyncio.sleep(60)

if __name__ == "__main__":
    # Ensure logs directory exists
    os.makedirs('logs', exist_ok=True)
    
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        logger.info("🏁 Node.js AI Agent shutdown complete")
    except Exception as e:
        logger.error(f"💥 Fatal error: {e}")
        sys.exit(1)
