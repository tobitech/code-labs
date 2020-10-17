import React, { Component } from 'react';

export default class Dropdown extends Component {

    constructor(props) {
        super(props)
        this.state = {
            isOpen: false
        }

        document.addEventListener('keydown', this.handleEscape);
    }

    componentWillUnmount() {
        document.removeEventListener('keydown', this.handleEscape);
    }

    handleEscape = (e) => {
        if (e.key === 'Esc' || e.key === 'Escape') {
            this.setState({ isOpen: false });
        }
    }

    render() {
        const { customclasses } = this.props;
        return (
            <div className={customclasses}>
                <div className="relative">
                    <button onClick={() => this.setState({ isOpen: !this.state.isOpen })} className="relative z-10 block h-8 w-8 rounded-full overflow-hidden border-2 border-gray-600 focus:outline-none focus:border-white">
                        <img className="h-full w-full object-cover object-center" src="/img/profile.jpg" alt="Your avatar" />
                    </button>
                    <button onClick={() => this.setState({ isOpen: false })} tabIndex="-1" className={`fixed inset-0 h-full w-full bg-black opacity-50 cursor-default ${this.state.isOpen ? "block" : "hidden"}`}></button>
                    <div className={`absolute right-0 mt-2 w-48 py-2 bg-white rounded-lg shadow-lg ${this.state.isOpen ? "block" : "hidden"}`}>
                        <a href="http://localhost:3000" className="block px-4 py-2 text-gray-800 hover:bg-indigo-500 hover:text-white">Account Settings</a>
                        <a href="http://localhost:3000" className="block px-4 py-2 text-gray-800 hover:bg-indigo-500 hover:text-white">Contact</a>
                        <a href="http://localhost:3000" className="block px-4 py-2 text-gray-800 hover:bg-indigo-500 hover:text-white">Sign out</a>
                    </div>
                </div>
            </div>
        )
    }
}
