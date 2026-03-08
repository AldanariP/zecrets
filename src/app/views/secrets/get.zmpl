<span id="cipher">{{.data.cipher}}</span>
<span id="iv">{{.data.iv}}</span>
<input id="once" type="checkbox"
@if ($.data.once == true)
 checked
@end
></input>

<main>
<div class="card">
    <div class="card-inner open">
        <textarea id="secret" class="blured">Lorem ipsum dolor sit amet, consectetur porttitor.</textarea>
        <button id="reveal">Reveal</button>
    </div>
</div>
</main>
