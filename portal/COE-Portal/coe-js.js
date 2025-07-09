/**
 * Power Platform CoE Portal - Custom JavaScript
 * Elections Canada Implementation
 * Requires jQuery (included with WET-BOEW)
 */

(function($) {
    'use strict';

    // Main CoE Portal functionality
    var CoEPortal = {
        
        // Configuration
        config: {
            animationDuration: 600,
            counterSpeed: 30,
            fadeInThreshold: 0.1
        },

        // Initialize the portal
        init: function() {
            this.handleAuthenticationState();
            this.initializeAnimations();
            this.setupAccessibility();
            this.bindEvents();
            this.loadDynamicContent();
        },

        // Handle user authentication state
        handleAuthenticationState: function() {
            var isAuthenticated = typeof user !== 'undefined' && user !== null;
            
            if (isAuthenticated) {
                $('.authenticated-services').show();
                $('.anonymous-info').hide();
                this.loadUserDashboard();
            } else {
                $('.authenticated-services').hide();
                $('.anonymous-info').show();
                this.initializeCounterAnimations();
            }
        },

        // Initialize animations and effects
        initializeAnimations: function() {
            // Fade in animation for elements
            this.setupFadeInObserver();
            
            // Service card hover effects
            this.setupServiceCardEffects();
            
            // Button ripple effects
            this.setupButtonEffects();
        },

        // Setup Intersection Observer for fade-in animations
        setupFadeInObserver: function() {
            if ('IntersectionObserver' in window) {
                var observer = new IntersectionObserver(function(entries) {
                    entries.forEach(function(entry) {
                        if (entry.isIntersecting) {
                            entry.target.classList.add('visible');
                        }
                    });
                }, {
                    threshold: this.config.fadeInThreshold
                });

                // Observe all service cards
                $('.service-card').each(function() {
                    this.classList.add('fade-in');
                    observer.observe(this);
                });
            }
        },

        // Initialize counter animations for statistics
        initializeCounterAnimations: function() {
            var self = this;
            
            // Only run for anonymous users
            if ($('.stats-section').length > 0) {
                var observer = new IntersectionObserver(function(entries) {
                    entries.forEach(function(entry) {
                        if (entry.isIntersecting) {
                            self.animateCounters();
                            observer.disconnect();
                        }
                    });
                });

                observer.observe($('.stats-section')[0]);
            }
        },

        // Animate statistics counters
        animateCounters: function() {
            var counters = [
                { id: 'active-apps', target: 250, suffix: '+' },
                { id: 'citizen-devs', target: 75, suffix: '+' },
                { id: 'environments', target: 12, suffix: '' },
                { id: 'processes', target: 180, suffix: '+' }
            ];

            counters.forEach(function(counter) {
                var element = document.getElementById(counter.id);
                if (element) {
                    CoEPortal.animateCounter(element, counter.target, counter.suffix);
                }
            });
        },

        // Animate individual counter
        animateCounter: function(element, target, suffix) {
            var current = 0;
            var increment = target / 50;
            var timer = setInterval(function() {
                current += increment;
                if (current >= target) {
                    element.textContent = target + suffix;
                    clearInterval(timer);
                } else {
                    element.textContent = Math.floor(current) + suffix;
                }
            }, this.config.counterSpeed);
        },

        // Setup service card effects
        setupServiceCardEffects: function() {
            $('.service-card').on('mouseenter', function() {
                $(this).find('.icon').addClass('pulse');
            }).on('mouseleave', function() {
                $(this).find('.icon').removeClass('pulse');
            });
        },

        // Setup button effects
        setupButtonEffects: function() {
            $('.btn-coe').on('click', function(e) {
                var button = $(this);
                var ripple = $('<span class="ripple"></span>');
                var rect = this.getBoundingClientRect();
                var size = Math.max(rect.width, rect.height);
                var x = e.clientX - rect.left - size / 2;
                var y = e.clientY - rect.top - size / 2;
                
                ripple.css({
                    width: size,
                    height: size,
                    left: x,
                    top: y
                }).appendTo(button);
                
                setTimeout(function() {
                    ripple.remove();
                }, 600);
            });
        },

        // Setup accessibility enhancements
        setupAccessibility: function() {
            // Add keyboard navigation for service cards
            $('.service-card').attr('tabindex', '0').on('keydown', function(e) {
                if (e.key === 'Enter' || e.key === ' ') {
                    e.preventDefault();
                    var link = $(this).find('a').first();
                    if (link.length) {
                        window.location.href = link.attr('href');
                    }
                }
            });

            // Add ARIA labels for statistics
            $('.stat-item').each(function() {
                var number = $(this).find('.stat-number').text();
                var label = $(this).find('.stat-label').text();
                $(this).attr('aria-label', number + ' ' + label);
            });

            // Announce dynamic content changes
            this.setupScreenReaderAnnouncements();
        },

        // Setup screen reader announcements
        setupScreenReaderAnnouncements: function() {
            // Create live region for announcements
            if ($('#sr-live-region').length === 0) {
                $('body').append('<div id="sr-live-region" aria-live="polite" aria-atomic="true" class="sr-only"></div>');
            }
        },

        // Announce message to screen readers
        announceToScreenReader: function(message) {
            $('#sr-live-region').text(message);
        },

        // Bind event handlers
        bindEvents: function() {
            var self = this;
            
            // Window resize handler
            $(window).on('resize', function() {
                self.handleResize();
            });

            // Error handling for service links
            $('.service-card a').on('click', function(e) {
                var href = $(this).attr('href');
                if (href && href.startsWith('/') && !self.isValidRoute(href)) {
                    e.preventDefault();
                    self.showServiceUnavailable($(this).closest('.service-card'));
                }
            });
        },

        // Handle window resize
        handleResize: function() {
            // Adjust layouts for mobile
            if ($(window).width() < 768) {
                $('.coe-hero').addClass('mobile');
            } else {
                $('.coe-hero').removeClass('mobile');
            }
        },

        // Check if route is valid (placeholder)
        isValidRoute: function(route) {
            // This would connect to your actual routing logic
            var validRoutes = ['/environment-request', '/dlp-request', '/app-catalog'];
            return validRoutes.includes(route);
        },

        // Show service unavailable message
        showServiceUnavailable: function(serviceCard) {
            var message = 'This service is currently being configured. Please check back soon.';
            var alert = $('<div class="alert alert-info" role="alert">' + message + '</div>');
            serviceCard.find('.btn-coe').after(alert);
            
            setTimeout(function() {
                alert.fadeOut(function() {
                    $(this).remove();
                });
            }, 5000);

            this.announceToScreenReader(message);
        },

        // Load dynamic content (for authenticated users)
        loadUserDashboard: function() {
            // This would connect to your Power Platform APIs
            this.loadUserStats();
            this.loadRecentActivity();
        },

        // Load user-specific statistics
        loadUserStats: function() {
            // Placeholder for API integration
            console.log('Loading user statistics...');
        },

        // Load recent user activity
        loadRecentActivity: function() {
            // Placeholder for API integration
            console.log('Loading recent activity...');
        },

        // Load additional dynamic content
        loadDynamicContent: function() {
            // Load announcements or news
            this.loadAnnouncements();
            
            // Load service status
            this.checkServiceStatus();
        },

        // Load system announcements
        loadAnnouncements: function() {
            // This would connect to your content management system
            console.log('Loading announcements...');
        },

        // Check service availability status
        checkServiceStatus: function() {
            // This would ping your service endpoints
            console.log('Checking service status...');
        },

        // Utility function for logging
        log: function(message, type) {
            if (type === 'error') {
                console.error('[CoE Portal Error]:', message);
            } else {
                console.log('[CoE Portal]:', message);
            }
        }
    };

    // Additional CSS for dynamic effects
    var additionalStyles = `
        <style>
            .pulse {
                animation: pulse 0.6s ease-in-out;
            }
            
            @keyframes pulse {
                0% { transform: scale(1); }
                50% { transform: scale(1.1); }
                100% { transform: scale(1); }
            }
            
            .ripple {
                position: absolute;
                border-radius: 50%;
                background: rgba(255,255,255,0.3);
                transform: scale(0);
                animation: ripple 0.6s linear;
                pointer-events: none;
            }
            
            @keyframes ripple {
                to {
                    transform: scale(4);
                    opacity: 0;
                }
            }
            
            .mobile .coe-hero h1 {
                font-size: 1.8rem !important;
            }
            
            .sr-only {
                position: absolute !important;
                width: 1px !important;
                height: 1px !important;
                padding: 0 !important;
                margin: -1px !important;
                overflow: hidden !important;
                clip: rect(0, 0, 0, 0) !important;
                white-space: nowrap !important;
                border: 0 !important;
            }
        </style>
    `;

    // Initialize when DOM is ready
    $(document).ready(function() {
        // Add additional styles
        $('head').append(additionalStyles);
        
        // Initialize the portal
        CoEPortal.init();
        
        // Make CoEPortal available globally for debugging
        window.CoEPortal = CoEPortal;
        
        CoEPortal.log('Portal initialized successfully');
    });

})(jQuery);