'use client'

import { useEffect, useState } from 'react'
import { Bot, CheckCircle, Clock } from 'lucide-react'

export default function AIStatusBanner() {
  const [productCount, setProductCount] = useState<number | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const fetchProductCount = async () => {
      try {
        const response = await fetch(`${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001'}/api/products`)
        const products = await response.json()
        setProductCount(products.length)
      } catch (error) {
        console.error('Error fetching products:', error)
        setProductCount(0)
      } finally {
        setLoading(false)
      }
    }

    fetchProductCount()
  }, [])

  return (
    <div className="bg-blue-50 border border-blue-200 rounded-lg p-4 mb-8">
      <div className="flex items-center">
        <Bot className="h-6 w-6 text-blue-600 mr-3" />
        <div>
          <strong className="text-blue-900">AI Agent Status:</strong>
          {loading ? (
            <span className="ml-2 text-blue-700">
              <Clock className="inline h-4 w-4 mr-1" />
              Connecting to AI systems...
            </span>
          ) : productCount && productCount > 0 ? (
            <span className="ml-2 text-green-700">
              <CheckCircle className="inline h-4 w-4 mr-1" />
              Active - Found {productCount} products in database
            </span>
          ) : (
            <span className="ml-2 text-yellow-700">
              🤖 AI agent is importing products (runs every 15 minutes)
            </span>
          )}
        </div>
      </div>
    </div>
  )
}
