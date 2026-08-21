async function readSecret(ciphertext, iv, deleteOnFirtsView, secretId) {
    const keyB64 = window.location.hash.slice(1);
    const secret = await decryptSecret(ciphertext, iv, keyB64);
    window.dispatchEvent(new CustomEvent("readsecret", {
        detail: {
            secret: secret,
            btnText: 'Copy'
        }
    }))
    if (deleteOnFirtsView) {
        await fetch(`/secret/${secretId}`, {method: "delete"});
    }
}

async function decryptSecret(ciphertextB64, ivB64, keyB64) {
    const key = await crypto.subtle.importKey("raw", fromB64(keyB64), {name: "AES-GCM"}, false, ["decrypt"]);
    const plaintext = await crypto.subtle.decrypt({name: "AES-GCM", iv: fromB64(ivB64)}, key, fromB64(ciphertextB64));
    return new TextDecoder().decode(plaintext);
}

function fromB64(b64) {
    return Uint8Array.from(atob(b64), c => c.charCodeAt(0));
}

async function copyLink(el, link) {
    await navigator.clipboard.writeText(link)
    el.dispatchEvent(new CustomEvent("copydone", {detail: {text: "Copied!"}}))
}
