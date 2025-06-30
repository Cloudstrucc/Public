import { Suspense } from 'react'
import HeroSection from '@/components/HeroSection'
import ProductGrid from '@/components/ProductGrid'
import AIStatusBanner from '@/components/AIStatusBanner'
import LoadingSpinner from '@/components/LoadingSpinner'

export default function HomePage() {
  return (
    <>
      <HeroSection />
      
      <section className="py-12 bg-gray-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <AIStatusBanner />
          
          <Suspense fallback={<LoadingSpinner />}>
            <ProductGrid />
          </Suspense>
        </div>
      </section>
    </>
  )
}
