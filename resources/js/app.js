import './bootstrap';

// Demo: Hot reload functionality
console.log('🚀 Laravel + Vite + Docker - Hot Reload Ready!');

// Add a simple interactive feature to test hot reload
document.addEventListener('DOMContentLoaded', function() {
    console.log('DOM loaded - Vite hot reload working!');
    
    // Add click handlers for demo purposes
    const buttons = document.querySelectorAll('button, a');
    buttons.forEach(btn => {
        btn.addEventListener('mouseenter', () => {
            console.log('Button hovered - hot reload is active!');
        });
    });
});
