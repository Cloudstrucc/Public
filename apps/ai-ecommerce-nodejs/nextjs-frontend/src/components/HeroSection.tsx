export default function HeroSection() {
  return (
    <section className="hero-gradient text-white py-20">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
        <div className="animate-fade-in">
          <h1 className="text-4xl md:text-6xl font-bold mb-6">
            🤖 AI-Powered E-commerce Platform
          </h1>
          <p className="text-xl md:text-2xl mb-8 text-blue-100">
            Discover amazing products sourced automatically by our AI agent from trusted suppliers worldwide
          </p>
          
          {/* Feature badges */}
          <div className="flex flex-wrap justify-center gap-4 mb-8">
            <span className="badge badge-ai">✨ AI-Powered</span>
            <span className="badge bg-white text-gray-900">🐘 PostgreSQL</span>
            <span className="badge bg-green-500 text-white">🇨🇦 Canadian Market</span>
            <span className="badge bg-yellow-500 text-white">⚡ Next.js SSR</span>
          </div>
          
          <a 
            href="#products" 
            className="btn-primary text-lg px-8 py-3 inline-block animate-pulse-slow"
          >
            Shop Now
          </a>
        </div>
      </div>
    </section>
  )
}
