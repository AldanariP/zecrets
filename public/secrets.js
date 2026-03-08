const id = window.location.pathname.split("/secrets/")[1];

const secret = document.getElementById("secret");
const revealBtn = document.getElementById("reveal");

revealBtn.addEventListener("click", async () => {
    secret.innerHTML = await readSecret();
    secret.classList.remove("blured");

    if (document.getElementById("once").checked) {
        await fetch(`/secrets/${id}`, {method: "DELETE"})
    }

    revealBtn.innerHTML = "Copy"
    revealBtn.addEventListener("click", async () => {
        await navigator.clipboard.writeText(secret.innerHTML)
        revealBtn.innerHTML = "Copied"
    })
})


async function readSecret() {
    const keyB64 = window.location.hash.slice(1);

    const ciphertext = document.getElementById("cipher").innerHTML;
    const iv = document.getElementById("iv").innerHTML;

    return await decryptSecret(ciphertext, iv, keyB64);
}

async function decryptSecret(ciphertextB64, ivB64, keyB64) {
    const key = await crypto.subtle.importKey("raw", fromB64(keyB64), {name: "AES-GCM"}, false, ["decrypt"]);
    const plaintext = await crypto.subtle.decrypt({name: "AES-GCM", iv: fromB64(ivB64)}, key, fromB64(ciphertextB64));
    return new TextDecoder().decode(plaintext);
}

function fromB64(b64) {
    return Uint8Array.from(atob(b64), c => c.charCodeAt(0));
}
