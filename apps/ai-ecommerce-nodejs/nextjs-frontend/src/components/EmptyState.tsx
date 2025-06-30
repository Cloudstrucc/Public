export default function EmptyState() {
  return (
    <div className="text-center py-16">
      <div className="mb-8">
        <span className="text-6xl">🤖</span>
      </div>
      <h3 className="text-2xl font-bold text-gray-900 mb-4">
        🤖 AI Agent is Working Hard!
      </h3>
      <p className="text-lg text-gray-600 mb-8 max-w-2xl mx-auto">
        Our artificial intelligence is currently importing products from suppliers around the world.
      </p>
      
      <div className="max-w-md mx-auto">
        <div className="card p-6">
          <h5 className="font-semibold mb-4">🔄 What's Happening?</h5>
          <ul className="text-left space-y-2 text-gray-600">
            <li>✅ PostgreSQL database is ready</li>
            <li>✅ Express.js API is connected</li>
            <li>🤖 Python AI agent is scraping products</li>
            <li>⏰ New products imported every 15 minutes</li>
          </ul>
          <hr className="my-4" />
          <p className="text-sm text-gray-500">
            <strong>Check back in a few minutes</strong> or watch the logs: 
            <code className="bg-gray-100 px-1 rounded ml-1">make logs-agent</code>
          </p>
        </div>
      </div>
    </div>
  )
}
