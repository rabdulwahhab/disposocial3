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
  }
}

export default Hooks
