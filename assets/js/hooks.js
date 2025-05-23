// assets/js/hooks.js
const Hooks = {
  GetLocation: {
    mounted() {
      if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition((position) => {
          const coords = {
            lat: position.coords.latitude,
            long: position.coords.longitude
          }
          this.pushEvent("location_updated", coords)
        })
      }
    }
  },
  EnterToSubmit: {
    mounted() {
      this.el.addEventListener("keydown", (e) => {
        if (e.key === "Enter" && !e.shiftKey) {
          e.preventDefault();
          this.el.form.dispatchEvent(
            new Event('submit', {bubbles: true, cancelable: true})
          );
        }
      });
    }
  },
  AutoScrollToBottom: {
    mounted() {
      console.log(1);
      this.scrollToBottom();
    },
    updated() {
      console.log(1);
      this.scrollToBottom();
    },
    scrollToBottom() {
      console.log(3);
      const el = this.el;
      el.scrollTop = el.scrollHeight;
      // el.scrollTo({top: el.scrollHeight, behavior: "smooth"});
    }
  }
}

export default Hooks
