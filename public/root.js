document.getElementById("until-date").value = new Date().toISOString().split("T")[0];

document.getElementById("btn-gen").addEventListener("click", () => {
    document.getElementById("form-card").classList.add("open")
    document.getElementById("btn-gen").addEventListener("click", getLink);
});

document.querySelectorAll('.tab').forEach(tab => {
    tab.addEventListener('click', () => {
        document.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));
        document.querySelectorAll('.picker').forEach(p => p.classList.remove('active'));
        tab.classList.add('active');
        document.getElementById('picker-' + tab.dataset.tab).classList.add('active');
    });
});

document.getElementById("copy").addEventListener("click", async () => {
    await navigator.clipboard.writeText(document.getElementById("link").innerHTML)
    document.getElementById("copy").innerHTML = "Copied"
})

async function getLink() {
    const options = {
        once: document.getElementById("firstview-input").checked,
    }
    switch (document.querySelector(".tab.active").dataset.tab) {
        case "duration":
            const durMin = parseInt(document.getElementById("dur-min").value)
            const durHrVal = parseInt(document.getElementById("dur-hr").value)
            let totalSeconds = 0;
            if (!isNaN(durMin)) totalSeconds += durMin * 60;
            if (!isNaN(durHrVal)) totalSeconds += durHrVal * 3600;
            if (totalSeconds > 0) {
                options.expires = totalSeconds;
            } else {
                alert("Invalid duration")
                return
            }
            break;
        case "until":
            const date = document.getElementById("until-date").value
            const time = document.getElementById("until-time").value
            const until = new Date(`${date}T${time}`)

            if (!isNaN(until.valueOf())) {
                if (until > new Date()) {
                    options.expires_at = until.getTime();
                } else {
                    alert("The date must be in the future")
                    return
                }
            } else {
                alert("Invalid date")
                return
            }
            break;
        default:
            alert("Please select a duration or an expiration date")
            return
    }

    const text = document.getElementById("secret").value
    if (text) {
        const link = await createLink(text.trim(), options)
        document.getElementById("link-card").classList.add("open")
        document.getElementById("link").innerHTML = link
    } else {
        alert("Please enter a secret")
    }
}

async function createLink(plaintext, options) {
    const {ciphertext, iv, key} = await encryptSecret(plaintext);

    const res = await fetch("/secrets", {
        method: "POST",
        headers: {"Content-Type": "application/json"},
        body: JSON.stringify({
            ciphertext: ciphertext,
            iv: iv,
            ...options
        }),
    });
    if (!res.ok) alert("Error creating link")
    const {id} = await res.json()

    return `${window.location.origin}/secrets/${id}#${key}`;
}

async function encryptSecret(plaintext) {
    const iv = crypto.getRandomValues(new Uint8Array(12));
    const key = await crypto.subtle.generateKey({name: "AES-GCM", length: 256}, true, ["encrypt", "decrypt"]);
    const ciphertext = await crypto.subtle.encrypt({name: "AES-GCM", iv}, key, new TextEncoder().encode(plaintext));
    const rawKey = await crypto.subtle.exportKey("raw", key);
    return {
        ciphertext: toB64(ciphertext),
        iv: toB64(iv),
        key: toB64(rawKey),
    };
}

function toB64(buffer) {
    return btoa(String.fromCharCode(...new Uint8Array(buffer)));
}