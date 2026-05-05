function post(action, data) {
    fetch(`https://${GetParentResourceName()}/${action}`, {
        method: "POST",
        body: JSON.stringify(data || {})
    });
}

const uiRoot = document.getElementById("lumber-ui");

function openUI(data) {
    uiRoot.classList.remove("hidden", "vorp-fade-out");
    uiRoot.classList.add("vorp-fade-in");
    switchTab("ledger");
    updateLedger(data);
}

function closeUI() {
    uiRoot.classList.remove("vorp-fade-in");
    uiRoot.classList.add("vorp-fade-out");
    setTimeout(() => {
        uiRoot.classList.add("hidden");
    }, 140);
}

window.addEventListener("message", function (event) {
    const data = event.data;

    if (data.action === "lumber_open") {
        openUI(data.data);
    }

    if (data.action === "lumber_open_ledger") {
        updateLedger(data.data);
    }

    if (data.action === "lumber_open_inventory") {
        updateInventory(data.data);
    }

    if (data.action === "lumber_open_upgrades") {
        updateUpgrades(data.data);
    }

    if (data.action === "lumber_open_stables") {
        updateStables(data.data);
    }
});

document.getElementById("close-btn").addEventListener("click", () => {
    closeUI();
    post("lumber_ui_close", {});
});

document.querySelectorAll("#tabs .tab-btn").forEach(btn => {
    btn.addEventListener("click", () => {
        post("lumber_ui_switch_tab", { tab: btn.dataset.tab });
    });
});

function switchTab(tabName) {
    document.querySelectorAll(".tab").forEach(t => t.classList.add("hidden"));
    const tab = document.getElementById(tabName);
    if (tab) tab.classList.remove("hidden");

    document.querySelectorAll("#tabs .tab-btn").forEach(b => {
        b.classList.toggle("active", b.dataset.tab === tabName);
    });
}

/* LEDGER */

function updateLedger(data) {
    document.getElementById("ledger-funds").innerText = "$" + (data.funds || 0);
    document.getElementById("ledger-income").innerText = "$" + (data.income || 0);
}

document.getElementById("ledger-deposit-btn").addEventListener("click", () => {
    const amount = Number(document.getElementById("ledger-deposit-amount").value) || 0;
    post("lumber_ledger_deposit", { amount });
});

document.getElementById("ledger-withdraw-btn").addEventListener("click", () => {
    const amount = Number(document.getElementById("ledger-withdraw-amount").value) || 0;
    post("lumber_ledger_withdraw", { amount });
});

/* UPGRADES */

function updateUpgrades(data) {}

document.getElementById("upgrade-office-btn").addEventListener("click", () => {
    post("lumber_upgrade_office", {});
});

document.querySelectorAll("#upgrades button[data-upgrade]").forEach(btn => {
    btn.addEventListener("click", () => {
        post("lumber_place_upgrade", {
            category: btn.dataset.category,
            upgradeType: btn.dataset.upgrade
        });
    });
});

/* STABLES */

function updateStables(data) {}

document.getElementById("upgrade-stables-btn").addEventListener("click", () => {
    post("lumber_upgrade_stables", {});
});

document.querySelectorAll("#stables button[data-wagon]").forEach(btn => {
    btn.addEventListener("click", () => {
        post("lumber_buy_wagon", { wagonType: btn.dataset.wagon });
    });
});

document.getElementById("set-wagon-spawn-btn").addEventListener("click", () => {
    post("lumber_set_wagon_spawn", {});
});

/* INVENTORY */

let dragSource = null;

function makeItemElement(item, count, context) {
    const el = document.createElement("div");
    el.classList.add("item");
    el.draggable = true;
    el.dataset.item = item;
    el.dataset.count = count;
    el.dataset.context = context;
    el.innerText = `${item} x${count}`;

    el.addEventListener("dragstart", (e) => {
        dragSource = { context, item, count };
        e.dataTransfer.effectAllowed = "move";
    });

    el.addEventListener("dragend", () => {
        dragSource = null;
    });

    return el;
}

function makeDropZone(element, onDropCallback) {
    element.addEventListener("dragover", (e) => {
        e.preventDefault();
        e.dataTransfer.dropEffect = "move";
    });

    element.addEventListener("drop", (e) => {
        e.preventDefault();
        if (!dragSource) return;
        onDropCallback(dragSource);
    });
}

function updateInventory(data) {
    const playerList = document.getElementById("player-items");
    const storageList = document.getElementById("storage-items");
    const storageSelect = document.getElementById("storage-select");

    playerList.innerHTML = "";
    storageList.innerHTML = "";
    storageSelect.innerHTML = "";

    if (data.playerItems) {
        data.playerItems.forEach(it => {
            playerList.appendChild(makeItemElement(it.name, it.count, "player"));
        });
    }

    Object.keys(data.storages || {}).forEach(storageName => {
        const opt = document.createElement("option");
        opt.value = storageName;
        opt.innerText = storageName;
        storageSelect.appendChild(opt);
    });

    storageSelect.onchange = () => {
        renderStorageItems(data, storageSelect.value);
    };

    if (storageSelect.options.length > 0) {
        storageSelect.selectedIndex = 0;
        renderStorageItems(data, storageSelect.value);
    }

    makeDropZone(playerList, (src) => {
        if (src.context === "storage") {
            const amount = prompt("Withdraw amount:", src.count);
            if (!amount) return;
            post("lumber_inventory_withdraw", {
                storage: storageSelect.value,
                item: src.item,
                amount: Number(amount)
            });
        }
    });

    makeDropZone(storageList, (src) => {
        if (src.context === "player")