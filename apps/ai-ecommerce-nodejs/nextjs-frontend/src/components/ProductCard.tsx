import Image from 'next/image'
import { Star, ShoppingCart, Eye } from 'lucide-react'

interface Product {
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

interface ProductCardProps {
  product: Product
}

export default function ProductCard({ product }: ProductCardProps) {
  const imageUrl = product.images[0] || 'https://via.placeholder.com/400x300?text=No+Image'
  
  const renderStars = (rating: number) => {
    return Array.from({ length: 5 }, (_, i) => (
      <Star
        key={i}
        className={`h-4 w-4 ${
          i < Math.floor(rating) ? 'text-yellow-400 fill-current' : 'text-gray-300'
        }`}
      />
    ))
  }

  return (
    <div className="card p-0 overflow-hidden animate-slide-up">
      {/* Sale badge */}
      {product.marketPrice < product.sourcePrice * 1.5 && (
        <div className="absolute top-2 right-2 z-10">
          <span className="badge badge-error">AI Priced</span>
        </div>
      )}

      {/* Product image */}
      <div className="relative h-48 bg-gray-100">
        <Image
          src={imageUrl}
          alt={product.title}
          fill
          className="object-cover"
          sizes="(max-width: 768px) 100vw, (max-width: 1200px) 50vw, 25vw"
        />
      </div>

      {/* Product details */}
      <div className="p-4">
        {/* Category */}
        <span className="badge badge-info mb-2">{product.category}</span>

        {/* Title */}
        <h3 className="font-semibold text-lg mb-2 line-clamp-2">{product.title}</h3>

        {/* Rating */}
        <div className="flex items-center mb-2">
          <div className="flex">
            {renderStars(product.rating)}
          </div>
          <span className="text-sm text-gray-600 ml-1">({product.reviewsCount})</span>
        </div>

        {/* Price */}
        <div className="mb-3">
          <div className="text-xl font-bold text-green-600">
            ${Number(product.marketPrice || 0).toFixed(2)} {product.currency}
          </div>
          {product.sourcePrice !== product.marketPrice && (
            <div className="text-sm text-gray-500 line-through">
              Was: ${Number(product.sourcePrice || 0).toFixed(2)} {product.currency}              
            </div>
          )}
        </div>

        {/* Availability */}
        <div className="mb-4">
          {product.availability ? (
            <span className="badge badge-success">✅ {product.inventoryLevel}</span>
          ) : (
            <span className="badge badge-error">❌ Out of Stock</span>
          )}
        </div>

        {/* Actions */}
        <div className="flex gap-2">
          {product.availability ? (
            <button className="btn-primary flex-1 flex items-center justify-center gap-2">
              <ShoppingCart className="h-4 w-4" />
              Add to Cart
            </button>
          ) : (
            <button className="btn-secondary flex-1" disabled>
              <span className="flex items-center justify-center gap-2">
                ❌ Out of Stock
              </span>
            </button>
          )}
          <button className="btn-secondary p-2">
            <Eye className="h-4 w-4" />
          </button>
        </div>
      </div>
    </div>
  )
}
