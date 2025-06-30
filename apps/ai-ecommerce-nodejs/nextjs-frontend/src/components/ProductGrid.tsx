import { fetchProducts } from '@/lib/api'
import ProductCard from './ProductCard'
import EmptyState from './EmptyState'

export default async function ProductGrid() {
  const products = await fetchProducts()

  if (!products || products.length === 0) {
    return <EmptyState />
  }

  return (
    <div className="animate-fade-in">
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
        {products.map((product) => (
          <ProductCard key={product.id} product={product} />
        ))}
      </div>
    </div>
  )
}
