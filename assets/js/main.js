// Mobile Navigation Toggle
const hamburger = document.querySelector('.hamburger');
const navMenu = document.querySelector('.nav-menu');

if (hamburger && navMenu) {
    hamburger.addEventListener('click', () => {
        hamburger.classList.toggle('active');
        navMenu.classList.toggle('active');
    });
}

// Smooth Scrolling for Navigation Links
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault();
        const target = document.querySelector(this.getAttribute('href'));
        if (target) {
            target.scrollIntoView({
                behavior: 'smooth',
                block: 'start'
            });
        }
    });
});

// Navbar Background on Scroll
window.addEventListener('scroll', () => {
    const navbar = document.querySelector('.navbar');
    if (window.scrollY > 100) {
        navbar.style.background = 'rgba(255, 255, 255, 0.98)';
    } else {
        navbar.style.background = 'rgba(255, 255, 255, 0.95)';
    }
});

// Animated Counter for Hero Stats
function animateCounters() {
    const counters = document.querySelectorAll('.stat-number');
    const speed = 200;

    counters.forEach(counter => {
        const animate = () => {
            const value = counter.innerText;
            const data = +value.replace(/[^\d.-]/g, '');
            const time = data / speed;

            if (data < +counter.getAttribute('data-target')) {
                counter.innerText = Math.ceil(data + time);
                setTimeout(animate, 1);
            } else {
                counter.innerText = counter.getAttribute('data-target') + 
                    (value.includes('%') ? '%' : 
                     value.includes('M') ? 'M+' : 
                     value.includes('K') ? 'K' : 
                     value.includes('s') ? 's' : 
                     value.includes('ms') ? 'ms' : '');
            }
        };
        animate();
    });
}

// Intersection Observer for Animations
const observerOptions = {
    threshold: 0.1,
    rootMargin: '0px 0px -50px 0px'
};

const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            entry.target.style.opacity = '1';
            entry.target.style.transform = 'translateY(0)';
            
            // Trigger counter animation for hero stats
            if (entry.target.classList.contains('hero-stats')) {
                // Set data targets for counters
                const statNumbers = entry.target.querySelectorAll('.stat-number');
                statNumbers.forEach(stat => {
                    const text = stat.innerText;
                    if (text.includes('99.9%')) {
                        stat.setAttribute('data-target', '99.9%');
                        stat.innerText = '0';
                    } else if (text.includes('10M+')) {
                        stat.setAttribute('data-target', '10M+');
                        stat.innerText = '0';
                    } else if (text.includes('50ms')) {
                        stat.setAttribute('data-target', '50ms');
                        stat.innerText = '0';
                    }
                });
                animateCounters();
            }
        }
    });
}, observerOptions);

// Observe elements for animation
document.addEventListener('DOMContentLoaded', () => {
    const animateElements = document.querySelectorAll('.feature-card, .pricing-card, .hero-stats');
    
    animateElements.forEach(el => {
        el.style.opacity = '0';
        el.style.transform = 'translateY(30px)';
        el.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
        observer.observe(el);
    });
});

// Dashboard Preview Tab Switching
const dashboardTabs = document.querySelectorAll('.tab');
dashboardTabs.forEach(tab => {
    tab.addEventListener('click', () => {
        // Remove active class from all tabs
        dashboardTabs.forEach(t => t.classList.remove('active'));
        // Add active class to clicked tab
        tab.classList.add('active');
        
        // Update dashboard content based on selected tab
        updateDashboardContent(tab.textContent);
    });
});

function updateDashboardContent(tabName) {
    const metricCards = document.querySelector('.metric-cards');
    if (!metricCards) return;

    const contentMap = {
        'Overview': [
            { value: '2.3s', label: 'Avg Response Time', trend: 'up', change: '↗ 15%' },
            { value: '99.8%', label: 'Success Rate', trend: 'up', change: '↗ 0.2%' },
            { value: '1.2K', label: 'Requests/min', trend: 'down', change: '↘ 5%' }
        ],
        'Metrics': [
            { value: '45ms', label: 'P95 Latency', trend: 'up', change: '↗ 8%' },
            { value: '2.1GB', label: 'Memory Usage', trend: 'down', change: '↘ 12%' },
            { value: '78%', label: 'CPU Usage', trend: 'up', change: '↗ 3%' }
        ],
        'Traces': [
            { value: '156', label: 'Active Traces', trend: 'up', change: '↗ 23%' },
            { value: '12ms', label: 'Trace Latency', trend: 'down', change: '↘ 7%' },
            { value: '98.9%', label: 'Trace Success', trend: 'up', change: '↗ 1.2%' }
        ],
        'Logs': [
            { value: '2.3M', label: 'Log Events', trend: 'up', change: '↗ 18%' },
            { value: '34', label: 'Error Count', trend: 'down', change: '↘ 22%' },
            { value: '1.2s', label: 'Index Time', trend: 'down', change: '↘ 15%' }
        ]
    };

    const content = contentMap[tabName] || contentMap['Overview'];
    
    metricCards.innerHTML = content.map(metric => `
        <div class="metric-card">
            <div class="metric-value">${metric.value}</div>
            <div class="metric-label">${metric.label}</div>
            <div class="metric-trend ${metric.trend}">${metric.change}</div>
        </div>
    `).join('');
}

// Performance Monitoring (DevOps Portfolio Feature)
class PerformanceMonitor {
    constructor() {
        this.metrics = {
            pageLoadTime: 0,
            firstContentfulPaint: 0,
            domContentLoaded: 0
        };
        this.collectMetrics();
    }

    collectMetrics() {
        // Page Load Time
        window.addEventListener('load', () => {
            this.metrics.pageLoadTime = performance.now();
            this.logMetric('Page Load Time', this.metrics.pageLoadTime);
        });

        // DOM Content Loaded
        document.addEventListener('DOMContentLoaded', () => {
            this.metrics.domContentLoaded = performance.now();
            this.logMetric('DOM Content Loaded', this.metrics.domContentLoaded);
        });

        // First Contentful Paint (if supported)
        if ('PerformanceObserver' in window) {
            const observer = new PerformanceObserver((list) => {
                for (const entry of list.getEntries()) {
                    if (entry.name === 'first-contentful-paint') {
                        this.metrics.firstContentfulPaint = entry.startTime;
                        this.logMetric('First Contentful Paint', entry.startTime);
                    }
                }
            });
            observer.observe({ entryTypes: ['paint'] });
        }
    }

    logMetric(name, value) {
        console.log(`[Performance] ${name}: ${Math.round(value)}ms`);
    }

    getHealthStatus() {
        return {
            status: 'healthy',
            timestamp: new Date().toISOString(),
            metrics: this.metrics,
            version: '1.0.0',
            environment: 'production'
        };
    }
}

// Initialize Performance Monitoring
const performanceMonitor = new PerformanceMonitor();

// Expose health check endpoint for container monitoring
window.getHealthStatus = () => performanceMonitor.getHealthStatus();

// Service Worker Registration (PWA capability for portfolio)
if ('serviceWorker' in navigator) {
    window.addEventListener('load', () => {
        navigator.serviceWorker.register('/sw.js')
            .then(registration => {
                console.log('[ServiceWorker] Registration successful');
            })
            .catch(error => {
                console.log('[ServiceWorker] Registration failed');
            });
    });
}

// Error Tracking (DevOps Portfolio Feature)
window.addEventListener('error', (event) => {
    console.error('[Error Tracking]', {
        message: event.message,
        filename: event.filename,
        lineno: event.lineno,
        colno: event.colno,
        error: event.error,
        timestamp: new Date().toISOString()
    });
});

window.addEventListener('unhandledrejection', (event) => {
    console.error('[Unhandled Promise Rejection]', {
        reason: event.reason,
        timestamp: new Date().toISOString()
    });
});

// A/B Testing Framework (DevOps Portfolio Feature)
class ABTestManager {
    constructor() {
        this.tests = {
            'hero-cta-color': {
                variants: ['primary', 'secondary'],
                active: true
            }
        };
        this.initializeTests();
    }

    initializeTests() {
        Object.keys(this.tests).forEach(testName => {
            if (this.tests[testName].active) {
                this.runTest(testName);
            }
        });
    }

    runTest(testName) {
        const test = this.tests[testName];
        const variant = test.variants[Math.floor(Math.random() * test.variants.length)];
        
        // Store variant in sessionStorage for consistency
        sessionStorage.setItem(`ab_test_${testName}`, variant);
        
        console.log(`[A/B Test] ${testName}: ${variant}`);
        return variant;
    }

    getVariant(testName) {
        return sessionStorage.getItem(`ab_test_${testName}`);
    }
}

// Initialize A/B Testing
const abTestManager = new ABTestManager();

// Feature Flags (DevOps Portfolio Feature)
class FeatureFlags {
    constructor() {
        this.flags = {
            'new-dashboard-ui': false,
            'advanced-analytics': true,
            'beta-features': false
        };
    }

    isEnabled(flagName) {
        return this.flags[flagName] || false;
    }

    enable(flagName) {
        this.flags[flagName] = true;
        console.log(`[Feature Flag] Enabled: ${flagName}`);
    }

    disable(flagName) {
        this.flags[flagName] = false;
        console.log(`[Feature Flag] Disabled: ${flagName}`);
    }
}

// Initialize Feature Flags
const featureFlags = new FeatureFlags();

// Make utilities available globally for debugging
window.heliosDevTools = {
    performance: performanceMonitor,
    abTest: abTestManager,
    features: featureFlags
}; 