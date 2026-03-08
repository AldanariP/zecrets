<main>
    <h1 class="headline">Shared once.<br><em>Gone forever.</em></h1>

    <div class="card">
        <textarea id="secret" placeholder="Paste your password, key, or any sensitive text…"></textarea>

        <div id="form-card" class="card-inner">
            <div id="expiry" class="expiry">
                 <div class="tabs">
                     <button class="tab active" data-tab="duration">Duration</button>
                     <button class="tab" data-tab="until">Until date</button>
                 </div>

                 <div class="picker active" id="picker-duration">
                     <div class="dur-group">
                         <div class="dur-field">
                             <input type="number" id="dur-min" min="0" max="59" value="0" placeholder="00">
                             <span class="dur-label">min</span>
                         </div>
                         <span class="dur-sep">+</span>
                         <div class="dur-field">
                             <input type="number" id="dur-hr" min="0" max="8760" value="24" placeholder="00">
                             <span class="dur-label">hr</span>
                         </div>
                     </div>
                 </div>

                 <div class="picker" id="picker-until">
                     <div class="until-group">
                         <input type="date" id="until-date">
                         <input type="time" id="until-time" value="12:00">
                     </div>
                 </div>

                 <div class="firstview">
                     <input type="checkbox" id="firstview-input">
                     <label for="firstview-input">
                         <span class="cb-box"></span>
                         Delete on first view
                     </label>
                 </div>
             </div>
        </div>
        <div id="gen-card" class="card-inner open">
            <button class="btn-gen" id="btn-gen">Generate link</button>
        </div>
        <div id="link-card" class="card-inner">
            <span id="link" class="link"></span>
            <button id="copy">Copy</button>
        </div>
    </div>
</main>
