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
          <b-col sm="4">Minimum Area <span class='unit'>mm<sup>2</sup></span></b-col>
          <b-col sm="8"><b-form-input type="number" v-model="minA" step=100></b-form-input></b-col>
        </b-row>
        <b-row class="my-1">
          <b-col sm="4">Minimum I <span class='unit'>10<sup>6</sup>mm<sup>4</sup></span></b-col>
          <b-col sm="8"><b-form-input type="number" v-model="minI" step=1></b-form-input></b-col>
        </b-row>
        <b-row class="my-1">
          <b-col sm="4">Minimum Radius <span class='unit'>mm</span></b-col>
          <b-col sm="8"><b-form-input type="number" v-model="minR" step=5></b-form-input></b-col>
        </b-row>
        <div class="spacer"></div>
        <h5>Compute Minimums:</h5>
        <b-row class="my-1">
          <b-col sm="4">Compressive</b-col>
          <b-col sm="8" id="compressive-checkbox"><b-form-checkbox v-model="compressive"></b-form-checkbox></b-col>
        </b-row>
        <b-row class="my-1">
          <b-col sm="4">Stiffness <span class='unit'>MPa</span></b-col>
          <b-col sm="8"><b-form-input type="number" v-model="stiffness" value=200000 step=100></b-form-input></b-col>
        </b-row>
        <b-row class="my-1">
          <b-col sm="4">Yield Strain <span class='unit'>MPa</span></b-col>
          <b-col sm="8"><b-form-input type="number" v-model="yieldStrain" value=350 step=100></b-form-input></b-col>
        </b-row>
        <b-row class="my-1">
          <b-col sm="4">Internal Force <span class='unit'>kN</span></b-col>
          <b-col sm="8"><b-form-input type="number" v-model="p" value=200000 step=100></b-form-input></b-col>
        </b-row>
        <b-row class="my-1">
          <b-col sm="4">Member Length <span class='unit'>m</span></b-col>
          <b-col sm="8"><b-form-input :disabled='!compressive' type="number" v-model="l" value=200000 step=100></b-form-input></b-col>
        </b-row>
        <b-button id="compute-button" @click="compute">Compute</b-button>
        <div class="spacer"></div>
        <h5>Best Option:</h5>
        <template v-if="bestHss">
          <p>{{ bestHss["hss"] }}</p>
          <div id="best-hss-meta">
            <p>Mass: {{ bestHss["mass"] }} <span class='unit'>kg/m</span></p>
            <p>Area: {{ bestHss["area"] }} <span class='unit'>mm<sup>2</sup></span></p>
            <p>I: {{ bestHss["i"] }} <span class='unit'>10<sup>6</sup>mm<sup>4</sup></span></p>
            <p>Radius: {{ bestHss["radius"] }} <span class='unit'>mm</span></p>
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
              <b-td @click="minA = sec.area">{{ sec.area }} </b-td>
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
    tenFOS: 2,
    comFOS: 3,

    minA: 0,
    minI: 0,
    minR: 0,

    compressive: true,
    stiffness: 200000,
    yieldStrain: 350,
    p: 0,
    l: 0
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
    },
    toSlideRule(num) {
      if (num === 0) {
        return 0;
      }
      const shifted = num * 10**(Math.ceil(Math.log10(1/num)));
      const prec = Math.floor(shifted) === 1 ? 4 : 3
      return num.toPrecision(prec);
    },
    calculateMinA(force, yieldStrain, FOS) {
      // Force in kN and yieldStrain in MPa. Returns A in mm^2
      return 1000*(FOS*force)/yieldStrain;
    },
    calculateMinI(force, length, stiffness, FOS) {
      // Force in kN, length in meters, stiffness in MPa. Returns I in 10^6*mm^4
      return (10**3)*(FOS*force*length**2)/(Math.PI**2 * stiffness);
    },
    calculateMinR(length) {
      // length in meters. Returns r in mm.
      return 1000*length/200;
    },
    compute() {
      // Computes minimum values based on forces and lengths.
      this.minA = this.toSlideRule(this.calculateMinA(this.p, this.yieldStrain, this.tenFOS));
      this.minR = this.compressive ? this.toSlideRule(this.calculateMinR(this.l)) : 0;
      this.minI = this.compressive ? this.toSlideRule(this.calculateMinI(this.p, this.l, this.stiffness, this.comFOS)) : 0;
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

  .unit {
    color: #b0b8bf;
    font-size: 13px;
  }

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
      display: flex;
      flex-direction: column;

      h5 {
        text-align: left;
      }

      #compute-button {
        margin-left: auto;
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

        #compressive-checkbox {
          text-align: left;
        }
      }
    }

    #table-container {
      width: 65%;

      .invalid {
        color: #b0b8bf;
      }
    }
  }
}
</style>
