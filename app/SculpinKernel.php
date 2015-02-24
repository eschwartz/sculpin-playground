<?php


use Sculpin\Bundle\SculpinBundle\HttpKernel\AbstractKernel;

class SculpinKernel extends AbstractKernel {

	/**
	 * Get additional Sculpin bundles to register
	 *
	 * @return array
	 */
	protected function getAdditionalSculpinBundles() {
		return [];
	}
}