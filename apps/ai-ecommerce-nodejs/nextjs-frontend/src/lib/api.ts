const API_URL = process.env.API_URL || 'http://localhost:3001'

export interface Product {
  id: string
  title: string
  description: string | null
  sourcePrice: number
  marketPrice: number
  currency: string
  images: string[]
  category: string
  availability: boolean
  rating: number
  reviewsCount: number
  inventoryLevel: string
}

export async function fetchProducts(): Promise<Product[]> {
  try {
    const response = await fetch(`${API_URL}/api/products`, {
      cache: 'no-store', // Always fetch fresh data
    })
    
    if (!response.ok) {
      throw new Error('Failed to fetch products')
    }
    
    return await response.json()
  } catch (error) {
    console.error('Error fetching products:', error)
    return []
  }
}

export async function fetchProduct(id: string): Promise<Product | null> {
  try {
    const response = await fetch(`${API_URL}/api/products/${id}`, {
      cache: 'no-store',
    })
    
    if (!response.ok) {
      return null
    }
    
    return await response.json()
  } catch (error) {
    console.error('Error fetching product:', error)
    return null
  }
}
