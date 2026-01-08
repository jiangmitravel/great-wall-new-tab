// 10 Great Wall background images
const backgrounds = [
    { path: 'images/backgrounds/great-wall-01.jpg', name: 'Great Wall View 1' },
    { path: 'images/backgrounds/great-wall-02.jpg', name: 'Great Wall View 2' },
    { path: 'images/backgrounds/great-wall-03.jpg', name: 'Great Wall View 3' },
    { path: 'images/backgrounds/great-wall-04.jpg', name: 'Great Wall View 4' },
    { path: 'images/backgrounds/great-wall-05.jpg', name: 'Great Wall View 5' },
    { path: 'images/backgrounds/great-wall-06.jpg', name: 'Great Wall View 6' },
    { path: 'images/backgrounds/great-wall-07.jpg', name: 'Great Wall View 7' },
    { path: 'images/backgrounds/great-wall-08.jpg', name: 'Great Wall View 8' },
    { path: 'images/backgrounds/great-wall-09.jpg', name: 'Great Wall View 9' },
    { path: 'images/backgrounds/great-wall-10.jpg', name: 'Great Wall View 10' }
];

// Randomly select a background image
function setRandomBackground() {
    const randomIndex = Math.floor(Math.random() * backgrounds.length);
    const selectedBg = backgrounds[randomIndex];

    const bgContainer = document.getElementById('background-container');
    const imageInfo = document.getElementById('image-name');

    // Set background image
    bgContainer.style.backgroundImage = `url('${selectedBg.path}')`;

    // Update image info
    if (imageInfo) {
        imageInfo.textContent = selectedBg.name;
    }
}

// Update time display
function updateTime() {
    const now = new Date();

    // Format time (HH:MM)
    const hours = String(now.getHours()).padStart(2, '0');
    const minutes = String(now.getMinutes()).padStart(2, '0');
    const timeString = `${hours}:${minutes}`;

    // Format date
    const options = {
        year: 'numeric',
        month: 'long',
        day: 'numeric',
        weekday: 'long'
    };
    const dateString = now.toLocaleDateString('en-US', options);

    // Update DOM
    const timeElement = document.getElementById('time');
    const dateElement = document.getElementById('date');

    if (timeElement) {
        timeElement.textContent = timeString;
    }

    if (dateElement) {
        dateElement.textContent = dateString;
    }
}

// Search box focus shortcut
function setupSearchShortcut() {
    const searchInput = document.getElementById('search-input');

    document.addEventListener('keydown', (e) => {
        // Press / key to focus search box
        if (e.key === '/' && document.activeElement !== searchInput) {
            e.preventDefault();
            searchInput.focus();
        }

        // Press Esc key to blur search box
        if (e.key === 'Escape' && document.activeElement === searchInput) {
            searchInput.blur();
        }
    });
}

// Initialization
document.addEventListener('DOMContentLoaded', () => {
    // Set random background
    setRandomBackground();

    // Update time
    updateTime();
    setInterval(updateTime, 1000); // Update every second

    // Set search shortcut
    setupSearchShortcut();
});
