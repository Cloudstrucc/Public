export default function LoadingSpinner() {
  return (
    <div className="flex flex-col items-center justify-center py-16">
      <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600 mb-4"></div>
      <h4 className="text-xl font-semibold text-gray-700">Loading Products from PostgreSQL...</h4>
      <p className="text-gray-500 mt-2">Our AI agent is fetching the latest products for you</p>
    </div>
  )
}
