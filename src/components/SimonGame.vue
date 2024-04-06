<script>
import { Sound } from "@/sound.js";
export default {
  data() {
    return {
      scope: 0,
      level: 0,
      gameMode: null,
      mods: {
        Easy: 1.5,
        Normal: 1,
        Hard: 0.4,
      },
      notification: {
        show: false,
        message: "",
        timer: null,
      },
      gameSubsequence: [],
      activeButton: null,
      sounds: [],
      playingSoundsInterval: null,
      isLose: false,
    };
  },
  methods: {
    nextLevel() {
      this.level++;
      this.gameSubsequence = this.getSubsequence();
      const subsequenceIterator = this.gameSubsequence[Symbol.iterator]();
      this.playingSoundsInterval = setInterval(() => {
        let soundIndex = subsequenceIterator.next().value;
        if (soundIndex === undefined) {
          this.activeButton = null;
          clearInterval(this.playingSoundsInterval);
          this.playingSoundsInterval = null;
        } else {
          this.activeButton = soundIndex;
          this.sounds[soundIndex].play();
          setTimeout(() => {
            this.activeButton = null;
          }, 100);
        }
      }, this.mods[this.gameMode] * 1000);
    },
    startGame() {
      this.scope = 0;
      this.level = 0;
      this.isLose = false;
      this.nextLevel();
    },
    finishGame() {
      this.isLose = true;
      this.gameSubsequence = [];
      this.addNotification("Game over");
    },
    addNotification(message) {
      clearTimeout(this.notification.timer);
      this.notification.message = message;
      this.notification.show = true;
      this.notification.timer = setTimeout(() => {
        this.notification.show = false;
        this.notification.message = "";
      }, this.gameMode * 1000);
    },
    getSubsequence() {
      return [...new Array(this.level)].map(() =>
        Math.floor(Math.random() * 4)
      );
    },
    clickSimonBtn(index) {
      if (this.playingSoundsInterval) {
        return;
      }
      if (this.level !== 0) {
        this.gameSubsequence.shift() === index
          ? this.scope++
          : this.finishGame();
      }
      this.sounds[index].play();
    },
  },
  watch: {
    gameSubsequence() {
      if (this.gameSubsequence.length === 0 && !this.isLose) {
        setTimeout(() => {
          this.nextLevel();
        }, 1000);
      }
    },
  },
  mounted() {
    this.sounds = [
      new Sound("/sounds/do.mp3"),
      new Sound("/sounds/lya.mp3"),
      new Sound("/sounds/si.mp3"),
      new Sound("/sounds/sol.mp3"),
    ];
  },
};
</script>

<template>
  <div class="simon_wapper">
    <div class="simon_title">
      <h1>Simon Game</h1>
    </div>
    <div v-if="!gameMode">
      <p style="margin-bottom: 20px; text-align: center">Choose game mode</p>
      <div class="simon_game-mode">
        <label
          class="simon_game-mode-item"
          v-for="(value, mode) in mods"
          :key="mode"
        >
          <input type="radio" v-model="gameMode" :value="mode" />
          <span>{{ mode }}</span>
        </label>
      </div>
    </div>
    <div v-else-if="!isLose">
      <div class="simon_game-mode">
        <span>Mode: {{ gameMode }}</span>
        <button @click="gameMode = null" class="simon_start_btn">
          Change mode
        </button>
        <button v-show="level === 0" @click="startGame" class="simon_start_btn">
          Start
        </button>
      </div>
      <div class="simon_info">
        <span>Level: {{ level }} </span>
        <span>Scope: {{ scope }}</span>
      </div>
    </div>
    <div v-show="gameMode && !isLose">
      <div id="simon" :class="{ 'not-clickable': !this.playingSoundsInterval }">
        <button
          class="simon_btn blue"
          @click="clickSimonBtn(0)"
          :class="{ active: activeButton === 0 }"
        />
        <button
          class="simon_btn red"
          @click="clickSimonBtn(1)"
          :class="{ active: activeButton === 1 }"
        />
        <button
          class="simon_btn green"
          @click="clickSimonBtn(2)"
          :class="{ active: activeButton === 2 }"
        />
        <button
          class="simon_btn yellow"
          @click="clickSimonBtn(3)"
          :class="{ active: activeButton === 3 }"
        />
      </div>
    </div>
    <div v-show="gameMode && isLose" class="simon_lose">
      <h2>You lose</h2>
      <h2>Scope: {{ scope }}</h2>
      <button
        @click="startGame"
        class="simon_start_btn"
        style="margin-top: 10px"
      >
        Restart
      </button>
    </div>
  </div>
</template>

<style scoped>
.simon_wapper {
  margin: auto;
  display: flex;
  justify-content: center;
  align-items: center;
  width: 100%;
  height: 100%;
  flex-direction: column;
  flex-wrap: nowrap;
}
#simon {
  width: 600px;
  height: 600px;
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  grid-template-rows: repeat(2, 1fr);
  grid-gap: 10px;
}
.simon_title {
  margin-bottom: 20px;
}
.simon_info {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  grid-template-rows: repeat(2, 1fr);
  grid-gap: 10px;
  margin-bottom: 20px;
  font-size: 20px;
  font-weight: bold;
}
.simon_start_btn {
  height: 50px;
  font-size: 20px;
  font-weight: bold;
  border-radius: 10px;
  border: 1px solid var(--color-border);
  background-color: var(--color-background-soft);
  color: var(--color-text);
  cursor: pointer;
  transition: 0.2s;
}
.simon_start_btn:hover {
  border: 1px solid var(--color-border-hover);
  background-color: var(--color-background-mute);
}
.simon_btn {
  border: 1px solid var(--color-border);
  border-radius: 10px;
  cursor: pointer;
  transition: 0.2s;
}
.simon_btn.blue {
  background-color: blue;
}
.simon_btn.red {
  background-color: red;
}
.simon_btn.green {
  background-color: green;
}
.simon_btn.yellow {
  background-color: yellow;
}
.not-clickable .simon_btn:active {
  border: 1px solid var(--color-border-hover);
  transform: scale(0.9);
}
.simon_btn.active {
  border: 1px solid var(--color-border-hover);
  filter: brightness(0.6);
  transform: scale(0.9);
}
.not-clickable .simon_btn:not(:active):hover {
  border: 1px solid var(--color-border-hover);
  filter: brightness(0.6);
}
.simon_game-mode {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  grid-gap: 10px;
  margin-bottom: 20px;
  align-items: center;
}
.simon_game-mode-item {
  display: flex;
  align-items: center;
  justify-content: center;
}
.simon_game-mode-item:hover {
  text-decoration: wavy underline overline;
}
.simon_game-mode-item input {
  position: absolute;
  z-index: -1;
  opacity: 0;
}
.simon_game-mode-item span {
  display: inline-flex;
  align-items: center;
  user-select: none;
  cursor: pointer;
}
.simon_game-mode-item input:checked + span {
  text-decoration: underline;
  color: var(--color-heading);
}
.simon_lose {
  text-align: center;
}
</style>
