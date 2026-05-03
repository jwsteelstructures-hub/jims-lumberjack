//------------------------------------------------------------
// POST HELPER
//------------------------------------------------------------
function post(action, data) {
    fetch(`https://${GetParentResourceName()}/${action}`, {
        method: "POST",
        body: JSON.stringify(data || {})
    });
}

//------------------------------------------------------------
// NUI MESSAGE HANDLER
//------------------------------------------------------------
window.addEventListener("message", function (event) {
    const data = event.data;

    if (data.action === "lumber_open") {
        document.getElementById("lumber-ui").classList.remove("hidden");
        switchTab("ledger");
        updateLedger(data.data);
    }

    if (data.action === "lumber_switch_tab") {
        switchTab(data.tab);
    }

    if (data.action === "lumber_open_ledger") {
        updateLedger(data.data);
    }

    if (data.action === "lumber_open_upgrades") {
        updateUpgrades(data.data);
    }

    if (data.action === "lumber_open_stables") {
        updateStables(data.data);
    }

    if (data.action === "lumber_open_inventory") {
        updateInventory(data.data);
    }

    if (data.action === "lumber_shop_open_employee") {
        switchTab("shop");
        updateShopEmployee(data.data);
    }

    if (data.action === "lumber_shop_open_customer") {
        switchTab("shop");
        updateShopCustomer(data.data);
    }

    if (data.action === "lumber_open_delivery") {
        updateDelivery(data.data);
    }
});

//------------------------------------------------------------
// CLOSE UI
//------------------------------------------------------------
document.getElementById("close-btn").addEventListener("click", () => {
    document.getElementById("lumber-ui").classList.add("hidden");
    post("lumber_ui_close", {});
});

//------------------------------------------------------------
// TAB SWITCHING
//------------------------------------------------------------
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


//------------------------------------------------------------
// LEDGER TAB
//------------------------------------------------------------
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

//------------------------------------------------------------
// UPGRADES TAB
//------------------------------------------------------------
function updateUpgrades(data) {
    // You can later highlight which upgrades are placed/unlocked
}

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

//------------------------------------------------------------
// STABLES TAB
//------------------------------------------------------------
function updateStables(data) {
    // You can later show which wagons are owned, stables phase, etc.
}

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

//------------------------------------------------------------
// DRAG & DROP CORE HELPERS
//------------------------------------------------------------
let dragSource = null; // { context: "player" | "storage" | "shopPlayer" | "shopStorage", item, count }

function makeItemElement(item, count, context) {
    const el = document.createElement("div");
    el.classList.add("item");
    el.draggable = true;
    el.dataset.item = item;
    el.dataset.count = count;
    el.dataset.context = context;
    el.innerText = `${item} x${count}`;

    el.addEventListener("dragstart", (e) => {
        dragSource = {
            context,
            item,
            count
        };
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

//------------------------------------------------------------
// INVENTORY TAB: PLAYER <-> STORAGE
//------------------------------------------------------------
function updateInventory(data) {
    const playerList = document.getElementById("player-items");
    const storageList = document.getElementById("storage-items");
    const storageSelect = document.getElementById("storage-select");

    playerList.innerHTML = "";
    storageList.innerHTML = "";
    storageSelect.innerHTML = "";

    // Player inventory is not provided by backend yet; you can later feed it.
    // For now, assume backend sends data.playerItems = [{name, count}]
    if (data.playerItems) {
        data.playerItems.forEach(it => {
            playerList.appendChild(makeItemElement(it.name, it.count, "player"));
        });
    }

    // Storages list
    Object.keys(data.storages || {}).forEach(storageName => {
        const opt = document.createElement("option");
        opt.value = storageName;
        opt.innerText = storageName;
        storageSelect.appendChild(opt);
    });

    // When storage changes, render its items
    storageSelect.addEventListener("change", () => {
        renderStorageItems(data, storageSelect.value);
    });

    if (storageSelect.options.length > 0) {
        storageSelect.selectedIndex = 0;
        renderStorageItems(data, storageSelect.value);
    }

    // Drop zones
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
        if (src.context === "player") {
            const amount = prompt("Deposit amount:", src.count);
            if (!amount) return;
            post("lumber_inventory_deposit", {
                storage: storageSelect.value,
                item: src.item,
                amount: Number(amount)
            });
        }
    });
}

function renderStorageItems(data, storageName) {
    const storageList = document.getElementById("storage-items");
    storageList.innerHTML = "";

    const storage = (data.storages && data.storages[storageName]) || { items: [] };

    (storage.items || []).forEach(it => {
        storageList.appendChild(makeItemElement(it.name, it.count, "storage"));
    });
}

//------------------------------------------------------------
// SHOP FRONT: EMPLOYEE (PLAYER <-> SHOP + PRICE)
//------------------------------------------------------------
let currentShopData = null;

function updateShopEmployee(data) {
    currentShopData = data;

    const playerList = document.getElementById("shop-player-items");
    const shopList = document.getElementById("shop-storage-items");

    playerList.innerHTML = "";
    shopList.innerHTML = "";

    // Same as inventory: you can later feed real player inventory
    if (data.playerItems) {
        data.playerItems.forEach(it => {
            playerList.appendChild(makeItemElement(it.name, it.count, "shopPlayer"));
        });
    }

    (data.items || []).forEach(it => {
        shopList.appendChild(makeItemElement(it.name, it.count, "shopStorage"));
    });

    // Drop zones
    makeDropZone(playerList, (src) => {
        if (src.context === "shopStorage") {
            const amount = prompt("Withdraw from shop:", src.count);
            if (!amount) return;
            post("lumber_shop_withdraw", {
                item: src.item,
                amount: Number(amount)
            });
        }
    });

    makeDropZone(shopList, (src) => {
        if (src.context === "shopPlayer") {
            const amount = prompt("Deposit into shop:", src.count);
            if (!amount) return;
            post("lumber_shop_deposit", {
                item: src.item,
                amount: Number(amount)
            });
        }
    });

    // Set price for last dragged shop item or manual input
    document.getElementById("shop-set-price-btn").onclick = () => {
        const price = Number(document.getElementById("shop-price-input").value) || 0;
        if (!dragSource || dragSource.context !== "shopStorage") {
            alert("Drag an item from shop inventory first to set its price.");
            return;
        }
        post("lumber_shop_set_price", {
            item: dragSource.item,
            price
        });
    };
}

//------------------------------------------------------------
// SHOP FRONT: CUSTOMER (SHOP -> PLAYER)
//------------------------------------------------------------
function updateShopCustomer(data) {
    const playerList = document.getElementById("shop-player-items");
    const shopList = document.getElementById("shop-storage-items");

    playerList.innerHTML = "";
    shopList.innerHTML = "";

    (data.items || []).forEach(it => {
        shopList.appendChild(makeItemElement(it.name, it.count, "shopStorage"));
    });

    // Customer can only drag from shop to player
    makeDropZone(playerList, (src) => {
        if (src.context === "shopStorage") {
            const amount = prompt("Buy amount:", src.count);
            if (!amount) return;
            post("lumber_shop_buy", {
                item: src.item,
                amount: Number(amount)
            });
        }
    });

    // No drop zone on shopList for customers
}

//------------------------------------------------------------
// DELIVERY TAB
//------------------------------------------------------------
function updateDelivery(data) {
    // You can later show storage counts, wagon availability, etc.
}

document.getElementById("start-delivery-btn").addEventListener("click", () => {
    const wagonType = document.getElementById("delivery-wagon-select").value;
    const species = document.getElementById("delivery-species-select").value;

    post("lumber_start_delivery", { wagonType, species });
});
