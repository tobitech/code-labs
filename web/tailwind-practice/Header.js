import React, { useState } from 'react';
import Dropdown from './Dropdown';

function Header() {
    const [isOpen, setIsOpen] = useState(false)
    return (
        <header className="bg-gray-900 sm:flex sm:justify-between sm:items-center sm:px-4 sm:py-3">
            <div className="flex items-center justify-between px-4 py-3 sm:p-0">
                <div className="text-white font-bold tracking-wide">
                    SIKWENS
                </div>
                <div className="sm:hidden">
                    <button type="button" onClick={() => setIsOpen(!isOpen)} className="block text-gray-500 hover:text-white focus:text-white focus:outline-none">
                        <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6 fill-current" viewBox="0 0 24 24">
                            {
                                isOpen ? <path fill-rule="evenodd" d="M18.278 16.864a1 1 0 0 1-1.414 1.414l-4.829-4.828-4.828 4.828a1 1 0 0 1-1.414-1.414l4.828-4.829-4.828-4.828a1 1 0 0 1 1.414-1.414l4.829 4.828 4.828-4.828a1 1 0 1 1 1.414 1.414l-4.828 4.829 4.828 4.828z" />
                                    : <path d="M4 5h16a1 1 0 0 1 0 2H4a1 1 0 1 1 0-2zm0 6h16a1 1 0 0 1 0 2H4a1 1 0 0 1 0-2zm0 6h16a1 1 0 0 1 0 2H4a1 1 0 0 1 0-2z" />
                            }
                        </svg>
                    </button>
                </div>
            </div>
            <div className={`${isOpen ? "block" : "hidden"} sm:block`}>
                <div className="px-2 pt-2 pb-4 sm:flex sm:p-0">
                    <a href="http://localhost:3000/properties" className="block px-2 py-1 text-white font-semibold rounded hover:bg-gray-800">List your property</a>
                    <a href="http://localhost:3000/trips" className="mt-1 block px-2 py-1 text-white font-semibold rounded hover:bg-gray-800 sm:mt-0 sm:ml-2">Trips</a>
                    <a href="http://localhost:3000/messages" className="mt-1 block px-2 py-1 text-white font-semibold rounded hover:bg-gray-800 sm:mt-0 sm:ml-2">Messages</a>
                    <Dropdown customclasses="hidden sm:block sm:ml-6"/>
                </div>
                <div className="px-4 py-5 border-t border-gray-800 sm:hidden">
                    <div className="flex items-center">
                        <img className="h-8 w-8 rounded-full border-2 border-gray-600 object-cover object-center" src="/img/profile.jpg" alt="Your avatar" />
                        <span className="ml-3 text-white font-semibold">Tobi Omotayo</span>
                    </div>
                    <div className="mt-4">
                        <a href="http://localhost:3000" className="block text-gray-400 hover:text-white">Account Settings</a>
                        <a href="http://localhost:3000" className="mt-2 block text-gray-400 hover:text-white">Contact</a>
                        <a href="http://localhost:3000" className="mt-2 block text-gray-400 hover:text-white">Sign out</a>
                    </div>
                </div>
            </div>
        </header>
    )
}

export default Header
