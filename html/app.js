console.log("Warmenu NUI Loaded");
const root = document.getElementById('wm-root');
const mainMenu = document.getElementById('wm-main');
const panels = {
    ledger: document.getElementById('panel-ledger'),
    upgrades: document.getElementById('panel-upgrades'),
    stables: document.getElementById('panel-stables'),
    inventory: document.getElementById('panel-inventory')
};

const items = Array.from(document.querySelectorAll('.wm-item'));
const desc = document.getElementById('wm-desc');

const descriptions = {
    ledger: 'Manage company funds, income, deposits and withdrawals.',
    upgrades: 'Upgrade office, storage, workstations and tents.',
    stables: 'Manage stables, wagons and spawn points.',
    inventory: 'Access company inventory (coming soon).'
};

let currentIndex = 0;
let inSubmenu = false;
let currentPanel = null;

function setSelected(index) {
    items.forEach((el, i) => {
        el.classList.toggle('selected', i === index);
    });
    const target = items[index].dataset.target;
    desc.textContent = descriptions[target] || '';
    currentIndex = index;
}

function openMainMenu() {
    inSubmenu = false;
    currentPanel = null;
    Object.values(panels).forEach(p => p.classList.add('hidden'));
    mainMenu.classList.remove('hidden');
    root.classList.remove('hidden');
    setSelected(currentIndex);
}

function openPanel(target) {
    inSubmenu = true;
    mainMenu.classList.add('hidden');
    Object.values(panels).forEach(p => p.classList.add('hidden'));
    const panel = panels[target];
    if (panel) {
        panel.classList.remove('hidden');
        currentPanel = target;
    }
}

function closeUI() {
    root.classList.add('hidden');
    inSubmenu = false;
    currentPanel = null;
    Object.values(panels).forEach(p => p.classList.add('hidden'));
    mainMenu.classList.remove('hidden');
}

window.addEventListener('keydown', (e) => {
    if (root.classList.contains('hidden')) return;

    // BACKSPACE: back / close
    if (e.key === 'Backspace') {
        e.preventDefault();
        if (inSubmenu) {
            openMainMenu();
        } else {
            closeUI();
            fetch(`https://${GetParentResourceName()}/close`, { method: 'POST', body: '{}' }).catch(() => {});
        }
        return;
    }

    if (inSubmenu) return;

    // UP/DOWN navigation
    if (e.key === 'ArrowUp') {
        e.preventDefault();
        currentIndex = (currentIndex - 1 + items.length) % items.length;
        setSelected(currentIndex);
    } else if (e.key === 'ArrowDown') {
        e.preventDefault();
        currentIndex = (currentIndex + 1) % items.length;
        setSelected(currentIndex);
    } else if (e.key === 'Enter') {
        e.preventDefault();
        const target = items[currentIndex].dataset.target;
        openPanel(target);
    }
});

// NUI open/close from Lua (Warmenu → NUI)
window.addEventListener('message', (event) => {
    const data = event.data;

    if (!data) return;

    if (data.action === 'open') {
        // Always unhide the root
        root.classList.remove('hidden');

        // If Warmenu sent a tab, open that panel directly
        if (data.tab) {
            openPanel(data.tab);
        } else {
            // Fallback: open main menu (legacy)
            openMainMenu();
        }

    } else if (data.action === 'close') {
        closeUI();

    } else if (data.action === 'updateLedger') {
        if (typeof data.funds !== 'undefined') {
            document.getElementById('ledger-funds').textContent = `$${data.funds}`;
        }
        if (typeof data.income !== 'undefined') {
            document.getElementById('ledger-income').textContent = `$${data.income}`;
        }
    }
});

