<template>
    <div class="appbar"
         :class="appbarDynamicClassName">
        <div id="appbar-window-control"
             v-if="shouldWindowCtlShow">
            <mu-icon-button @click="handleClose"
                            icon="close" />
            <mu-icon-button @click="handleMaximize"
                            icon="keyboard_arrow_up" />
            <mu-icon-button @click="handleMinimize"
                            icon="keyboard_arrow_down" />
        </div>
        <mu-appbar title="Electron Netease Cloud Music">
            <mu-icon-button icon="menu"
                            slot="left"
                            @click="toggleDrawer" />
            <mu-auto-complete icon="search"
                              slot="right"
                              class="appbar-search-field"
                              inputClass="appbar-search-input"
                              hintText="搜索歌曲、歌单、用户"
                              :maxHeight="400"
                              openOnFocus
                              v-model="searchText"
                              :dataSource="searchAutoComplete"
                              @input="handleSearchInput"
                              @keyup.enter="handleSearch" />
        </mu-appbar>
        <mu-drawer :width="300"
                   :open="drawerOpen"
                   :docked="false"
                   @close="toggleDrawer()">
            <mu-list class="appnav-drawer">
                <div class="header"
                     :style="backgroundUrlStyle">
                    <div class="user-info">
                        <mu-avatar :icon="loginValid ? null : 'music_note'"
                                   :src="user.avatarUrl"
                                   :iconSize="40"
                                   :size="80" />
                        <span class="user-name"
                              @click="handleNameClick">{{user.name}}</span>
                        <mu-flat-button v-if="loginValid"
                                        label="签到"
                                        class="button-checkin"
                                        color="white"
                                        @click="handleCheckIn" />
                    </div>
                </div>
                <router-link to='/'>
                    <mu-list-item title="个性推荐">
                        <mu-icon slot="left"
                                 value="polymer" />
                    </mu-list-item>
                </router-link>
                <router-link to="/myplaylist">
                    <mu-list-item title="我的歌单">
                        <mu-icon slot="left"
                                 value="library_music" />
                    </mu-list-item>
                </router-link>
                <mu-list-item title="听歌排行">
                    <mu-icon slot="left"
                             value="equalizer" />
                </mu-list-item>
                <mu-list-item title="本地音乐">
                    <mu-icon slot="left"
                             value="desktop_mac" />
                </mu-list-item>
                <router-link to="/settings">
                    <mu-list-item title="应用设置">
                        <mu-icon slot="left"
                                 value="settings" />
                    </mu-list-item>
                </router-link>
            </mu-list>
        </mu-drawer>
        <mu-dialog dialogClass="nav-login-dlg"
                   :open="dlgShow"
                   title="登录"
                   @close="toggleDlg">
            <mu-text-field label="用户名/邮箱/手机号"
                           inputClass="app-nav-input-account"
                           v-model="inputUsr"
                           :errorText="errMsgUsr"
                           fullWidth
                           labelFloat/>
            <br/>
            <mu-text-field label="密码"
                           id="app-nav-input-password"
                           type="password"
                           v-model="inputPwd"
                           :errorText="errMsgPwd"
                           fullWidth
                           labelFloat/>
            <br/>
            <div v-if="needCaptcha">
                <mu-text-field label="验证码"
                               class="text-field-captcha"
                               v-model="inputCaptcha"
                               :errorText="errMsgCaptcha"
                               labelFloat/>
                <img :src="`http://music.163.com/captcha?id=${captchaId}`"
                     class="captcha-img"
                     alt="Refresh" />
                <br/>
            </div>
            <br/>
            <mu-raised-button label="登录"
                              fullWidth
                              primary
                              @click="handleLogin" />
        </mu-dialog>
    </div>
</template>

<script>
import { mapActions, mapGetters } from 'vuex';
import { remote } from 'electron';

import ApiRenderer from '../util/apirenderer';
import { searchIconMap } from '../util/searchtype';

export default {
    data() {
        return {
            currentWindow: remote.getCurrentWindow(),
            isDarwin: process.platform === 'darwin',
            searchText: '',
            searchAutoComplete: [],
            drawerOpen: false,
            dlgShow: false,
            inputUsr: '',
            inputPwd: '',
            errMsgUsr: '',
            errMsgPwd: '',
            needCaptcha: false,
            captchaId: null,
            inputCaptcha: '',
            errMsgCaptcha: ''
        };
    },
    computed: {
        currentSettings() {
            return this.$store.state.settings;
        },
        appbarDynamicClassName() {
            return [
                this.isDarwin && 'appbar-darwin',
                this.shouldWindowCtlShow && 'appbar-with-ctl'
            ];
        },
        shouldWindowCtlShow() {
            return !this.isDarwin && !this.currentSettings.windowBorder;
        },
        backgroundUrlStyle() {
            return this.user.bkgUrl && `background-image: url(${this.user.bkgUrl})`;
        },
        ...mapGetters([
            'loginValid',
            'user'
        ])
    },
    methods: {
        ...mapActions([
            'setUserInfo'
        ]),
        handleClose() {
            this.currentWindow.close();
        },
        handleMinimize() {
            this.currentWindow.minimize();
        },
        handleMaximize() {
            if (this.currentWindow.isMaximized())
                this.currentWindow.unmaximize();
            else
                this.currentWindow.maximize();
        },
        toggleDrawer() {
            this.drawerOpen = !this.drawerOpen;
        },
        handleNameClick() {
            if (!this.loginValid) {
                this.dlgShow = true;
                this.$nextTick(() => {
                    const inputAccRef = document.querySelector('.app-nav-input-account');
                    const inputPwdRef = document.querySelector('#app-nav-input-password');
                    inputPwdRef.addEventListener('keydown', e => e.key === 'Enter' && this.handleLogin());
                    setTimeout(() => inputAccRef.focus(), 200);
                });
            }
        },
        toggleDlg() {
            this.dlgShow = !this.dlgShow;
        },
        async handleLogin() {
            this.errMsgUsr = '';
            this.errMsgPwd = '';
            if (!this.inputUsr) return this.errMsgUsr = '用户名不能为空';
            if (!this.inputPwd) return this.errMsgPwd = '密码不能为空';
            // TODO: Login with captcha
            let resp = await ApiRenderer.login(this.inputUsr, this.inputPwd);
            switch (resp.code) {
                case 200:
                    const cookie = await ApiRenderer.getCookie();
                    this.setUserInfo({ cookie, info: resp });
                    this.toggleDlg();
                    localStorage.setItem('cookie', JSON.stringify(cookie));
                    localStorage.setItem('user', JSON.stringify(resp));
                    localStorage.setItem('uid', resp.account.id);
                    break;
                case 415:
                    this.errMsgCaptcha = '登录过于频繁，请输入验证码';
                    this.captchaId = resp.captchaId;
                    this.needCaptcha = true;
                case 501:
                    this.errMsgUsr = '用户不存在';
                    break;
                case 502:
                    this.errMsgPwd = '密码错误';
                    break;
                default:
                    this.errMsgUsr = resp.msg;
            }
        },
        async handleCheckIn() {
            let results = [
                await ApiRenderer.postDailyTask(0),
                await ApiRenderer.postDailyTask(1)
            ];
            let points = 0;
            results.forEach(e => e.code === 200 ? points += e.point : null);
            if (points) {
                this.$toast(`签到成功，获得 ${points} 点积分`);
            } else {
                this.$toast('是不是已经签到过了呢 ：）');
            }
        },
        async handleSearchInput() {
            const resp = await ApiRenderer.getSearchSuggest(this.searchText);
            if (resp.code === 200) {
                let tmp = [];
                for (const key in resp.result) {
                    const current = resp.result[key];
                    if (Array.isArray(current) && typeof current[0] === 'object') {
                        tmp.push(...current.map(e => ({
                            text: e.name,
                            rightIcon: searchIconMap[key]
                        })));
                    }
                }
                this.searchAutoComplete = tmp;
            } else {
                this.searchAutoComplete = [];
            }
        },
        handleSearch() {
            this.$router.push(`/search?q=${this.searchText}`);
        }
    },
    created() {
        this.$router.afterEach(() => this.drawerOpen = false);
    },
    mounted() {
        document.querySelector('.appbar-search-input').onkeydown = ev => {
            if (ev.key === 'Enter') this.handleSearch();
        };
    }
};
</script>

<style lang="less">
.appbar {
    cursor: default;
    user-select: none;
    -webkit-app-region: drag;
    .mu-appbar {
        .left {
            cursor: pointer;
            -webkit-app-region: no-drag;
        }
    }
}

#appbar-window-control {
    z-index: 10;
    -webkit-app-region: no-drag;
    transform: scale(0.6);
    position: absolute;
    left: -27px;
    top: -9px;
    color: white;
    button {
        cursor: default !important;
        margin-right: -2px;
        .mu-ripple-wrapper {
            border-radius: 100%;
            transition: background-color 0.2s;
        }
        &:hover .mu-ripple-wrapper {
            background-color: rgba(0, 0, 0, 0.1);
        }
    }
}

.appbar-with-ctl {
    .mu-appbar {
        padding-top: 16px;
    }
}

.appbar-no-ctl {
    .mu-appbar {
        padding-top: 0;
    }
    #appbar-window-control {
        display: none;
    }
}

.appbar-darwin {
    padding-top: 12px;
}

.appbar-search-field {
    .mu-text-field {
        color: #FFF;
        margin-bottom: 0;
        -webkit-app-region: no-drag;
        &.focus-state {
            color: #FFF;
        }
        .mu-text-field-hint {
            color: fade(#FFF, 54%);
        }
        .mu-text-field-input {
            color: #FFF;
        }
        .mu-text-field-focus-line {
            background-color: #FFF;
        }
    }
}

.appnav-drawer {
    padding-top: 0;
    .header {
        position: relative;
        width: 100%;
        height: 200px;
        background-size: cover;
        background-image: url(../../../assets/img/TealRedYellow.png);
        background-position-y: 50%;
        &::before {
            position: absolute;
            content: "cnt";
            color: transparent;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.2);
        }
        .user-info {
            position: absolute;
            padding: 2rem;
            bottom: 0;
            left: 0;
            .mu-avatar {
                display: block;
            }
            .user-name {
                margin-top: 1rem;
                color: white;
                font-size: 2rem;
                cursor: pointer;
                display: inline-block;
                line-height: 36px;
                width: 160px;
                white-space: nowrap;
                overflow: hidden;
                text-overflow: ellipsis;
                vertical-align: bottom;
            }
            .button-checkin {
                display: inline-block;
            }
        }
    }
}

.nav-login-dlg {
    width: 400px;
    .text-field-captcha {
        display: inline-block;
        width: 200px;
    }
    .captcha-img {
        width: 122px;
        height: 60px;
        float: right;
    }
}
</style>
