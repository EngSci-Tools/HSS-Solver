<template>
  <div id="app">
    <div id="titleBox">
      <h2>Don't waste your time searching through that table.</h2>
      <p>Filter by Area, I, or r and get the square HSS that minimizes that mass automatically.</p>
    </div>
    <div id="searcher">
      <div id="filter-container">
        <h5>Filter:</h5>
        <b-row class="my-1">
          <b-col sm="3">Minimum Area</b-col>
          <b-col sm="9"><b-form-input type="number" v-model="minA"></b-form-input></b-col>
        </b-row>
        <b-row class="my-1">
          <b-col sm="3">Minimum I</b-col>
          <b-col sm="9"><b-form-input type="number" v-model="minI"></b-form-input></b-col>
        </b-row>
        <b-row class="my-1">
          <b-col sm="3">Minimum Radius</b-col>
          <b-col sm="9"><b-form-input type="number" v-model="minR"></b-form-input></b-col>
        </b-row>
        <div class="spacer"></div>
        <h5>Best Option:</h5>
        <template v-if="bestHss">
          <p>{{ bestHss["hss"] }}</p>
          <div id="best-hss-meta">
            <p>Mass: {{ bestHss["mass"] }}</p>
            <p>I: {{ bestHss["i"] }}</p>
            <p>Radius: {{ bestHss["radius"] }}</p>
          </div>
        </template>
        <template v-else>
          <p>No HSS is available</p>
        </template>
      </div>
      <div id="table-container">
        <b-table-simple striped bordered hover sticky-header="100%">
          <b-thead>
            <b-tr>
              <b-th>HSS</b-th>
              <b-th>Mass <span class='unit'>kg/m</span></b-th>
              <b-th>Area <span class='unit'>mm<sup>2</sup></span></b-th>
              <b-th>I <span class='unit'>10<sup>6</sup>mm<sup>4</sup></span></b-th>
              <b-th>Radius <span class='unit'>mm</span></b-th>
            </b-tr>
          </b-thead>
          <b-tbody>
            <b-tr v-for="sec in hss" :key="sec.mass" :class="{ invalid: !hssIsValid(sec) }">
              <b-td @click='overwriteMins(sec)'>{{ sec.hss }}</b-td>
              <b-td @click='overwriteMins(sec)'>{{ sec.mass }}</b-td>
              <b-td @click="minA = sec.area">{{ sec.area }}</b-td>
              <b-td @click="minI = sec.i">{{ sec.i }}</b-td>
              <b-td @click="minR = sec.radius">{{ sec.radius }}</b-td>
            </b-tr>
          </b-tbody>
        </b-table-simple>
      </div>
    </div>
  </div>
</template>

<script>
import hss from './assets/hss-v1.json';

export default {
  name: 'App',
  data: () => ({
    minA: 0,
    minI: 0,
    minR: 0
  }),
  computed: {
    hss() {
      function getWidthHeightDepth(sectionName) {
        // Gets the width, height and cross sectional depth. Not used for anything at the moment
        const dims = sectionName.substring(4).split("x").map(dim => parseInt(dim));
        return {"width": dims[0], "height": dims[1], "depth": dims[2]}
      } 
      // Turns the object into an array of objects with keys - ["hass", "width", "height", "depth", "mass", "area", "i", "radius"]
      return Object.keys(hss).map(key => ({"hss": key, ...getWidthHeightDepth(key), ...hss[key]}))
    },
    bestHss() {
      // Finds the hss with the lowest mass that fits the minimum area, i, and r.
      return [...this.hss].filter(sec => this.hssIsValid(sec)).sort((a, b) => a.mass - b.mass)[0];
    }
  },
  methods: {
    hssIsValid(sec) {
      return sec.area >= this.minA && sec.i >= this.minI && sec.radius >= this.minR
    },
    overwriteMins(sec) {
      // Used to overwrite all the minimums when a user clicks on a row.
      ({
        area: this.minA,
        i: this.minI,
        radius: this.minR
      } = sec)
    }
  }
}
</script>

<style lang="less">
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  display: flex;
  flex-direction: column;

  #titleBox {
    margin: 30px;
  }

  #searcher {
    width: 100%;
    display: flex;
    flex-direction: row;

    #filter-container {
      width: 35%;
      padding: 10px;

      h5 {
        text-align: left;
      }

      .spacer {
        width: 100%;
        height: 50px;
      }

      #best-hss-meta {
        p {
          margin: 0;
        }
      }

      .row {
        display: flex;
        flex-direction: row;
        align-items: center;
      }
    }

    #table-container {
      width: 65%;

      .invalid {
        color: #b0b8bf;
      }

      .unit {
        color: #b0b8bf;
        font-size: 13px;
      }
    }
  }
}
</style>
