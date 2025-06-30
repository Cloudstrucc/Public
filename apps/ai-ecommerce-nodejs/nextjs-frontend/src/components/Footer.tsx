export default function Footer() {
  return (
    <footer className="bg-gray-900 text-white">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
          {/* Brand */}
          <div className="col-span-1 md:col-span-2">
            <div className="flex items-center space-x-2 mb-4">
              <span className="text-2xl">🤖</span>
              <span className="text-xl font-bold">AI E-commerce Platform</span>
            </div>
            <p className="text-gray-400 mb-4">
              Powered by artificial intelligence for automated product sourcing, 
              intelligent pricing, and market research.
            </p>
          </div>

          {/* Technology Stack */}
          <div>
            <h6 className="font-semibold mb-4">Technology Stack</h6>
            <ul className="space-y-2 text-gray-400">
              <li>🐘 PostgreSQL Database</li>
              <li>⚡ Next.js & React</li>
              <li>🚀 Express.js API</li>
              <li>🤖 Python AI Agent</li>
            </ul>
          </div>

          {/* Features */}
          <div>
            <h6 className="font-semibold mb-4">Features</h6>
            <ul className="space-y-2 text-gray-400">
              <li>✅ Real-time Product Import</li>
              <li>✅ Intelligent Pricing</li>
              <li>✅ Canadian Market Focus</li>
              <li>✅ Mobile Responsive</li>
            </ul>
          </div>
        </div>

        <hr className="my-8 border-gray-800" />
        
        <div className="text-center text-gray-400">
          <p>© 2024 AI E-commerce Platform. Built with ❤️ for Canadian entrepreneurs.</p>
        </div>
      </div>
    </footer>
  )
}
